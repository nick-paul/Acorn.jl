# """ Clear the screen, print an error message, and kill the program """
# function die(msg)
#     write(STDOUT, "\x1b[2J")
#     write(STDOUT, "\x1b[H")
#     error(msg)
# end


##########
# CURSOR #
##########

mutable struct Cursor
    x::Int
    y::Int
    rx::Int
end


##########
# EDITOR #
##########
"Editor instance"
mutable struct Editor
    "row view offset"
    rowoff::Int
   
    "column view offset"
    coloff::Int

    "terminal width"
    width::Int
    
    "terminal height"
    height::Int
    
    "currently edited file"
    filename::String
    
    "current status message"
    statusmsg::String
    
    "time reaining to display status"
    status_time::Float64

    "true if the buffer has been edited"
    dirty::Bool

    "if true, the key input loop will exit"
    quit::Bool

    "the cursor position"
    csr::Cursor

    "the test buffer"
    rows::Rows

    "terminal hosting this editor"
    term::Base.Terminals.TTYTerminal

    "used by commands to store variables"
    params::Dict{Symbol, Dict{Symbol, Any}}
end

"""create a new editor with default params"""
function Editor()
    rowoff = 0
    coloff = 0
    width = 0
    height = 0
    filename = ""
    statusmsg = ""
    status_time = 0
    dirty = false
    quit = false

    csr = Cursor(1,1,1)
    rows = Rows()
    term = Base.Terminals.TTYTerminal(get(ENV, "TERM", @static is_windows() ? "" : "dumb"), STDIN, STDOUT, STDERR)
    
    params = Dict{Symbol, Dict{Symbol, Any}}()

    Editor(rowoff, coloff, width, height, filename,
        statusmsg, status_time, dirty, quit,
        csr, rows, term, params)
end




###################
# FILE OPERATIONS #
###################

""" Open a file and read the lines into the ed.rows array """
function editorOpen(ed::Editor, filename::String)
    try
        filename = expanduser(filename)

        # If no file exists, create it
        !isfile(filename) && open(filename, "w") do f end

        open(filename, "r") do file
            clearRows(ed.rows)
            for line in eachline(file)
                appendRow(ed.rows, line)
            end
            ed.filename = filename
            ed.csr.x = 1
            ed.csr.y = 1
            ed.dirty = false
        end
    catch Exception e
        setStatusMessage(ed, "Cannot open file $filename")
    end
end


function editorOpen(ed::Editor)
    if ed.dirty
        confirm = editorPrompt(ed, "There are unsaved changes. Open another file? [y/n]: ")
        if confirm != "y"
            setStatusMessage(ed, "Open aborted")
            return
        end
    end

    filename = editorPrompt(ed, "Open file: ")
    filename = expand(filename)

    if filename != ""
        editorOpen(ed, filename)
    else
        setStatusMessage(ed, "Open aborted")
    end
end

""" Save the buffer to the file using the current file name """
function editorSave(ed::Editor)
    editorSave(ed, "")
end

""" Save the contents of the file buffer to disc """
function editorSave(ed::Editor, path::String)
    prev_filename = ed.filename

    try
        if path == ""
            if ed.filename == ""
                ed.filename = editorPrompt(ed, "Save as: ")
                if ed.filename == ""
                    setStatusMessage(ed, "Save aborted")
                    return
                end
            end
        else
            ed.filename = expand(path)
        end

        open(ed.filename, "w") do f
            write(f, rowsToString(ed.rows))
        end
        setStatusMessage(ed, "File saved: $(ed.filename)")
        ed.dirty = false
    catch Exception
        # There was an error saving, restore original filename
        ed.filename = prev_filename
        setStatusMessage(ed, "Unable to save: $(ed.filename)")
    end
end



##########
# VISUAL #
##########

""" Given an arrow input, move the cursor """
function moveCursor(ed::Editor, key::UInt32)
    if key == ARROW_LEFT
        if ed.csr.x > 1
            ed.csr.x -= 1
        elseif ed.csr.y > 1
            # At start of line, move to end of prev line
            ed.csr.y -= 1
            ed.csr.x = 1+length(ed.rows[ed.csr.y].chars)
        end

    elseif key == ARROW_RIGHT
        onrow = ed.csr.y <= length(ed.rows)
        if onrow && ed.csr.x <= length(ed.rows[ed.csr.y].chars)
            ed.csr.x += 1
        elseif ed.csr.y < length(ed.rows) && ed.csr.x == 1 + length(ed.rows[ed.csr.y].chars)
            # At end of line, move to next line
            ed.csr.y += 1
            ed.csr.x = 1
        end

    elseif key == ARROW_UP
        ed.csr.y > 1 && (ed.csr.y -= 1)

    elseif key == ARROW_DOWN
        ed.csr.y < length(ed.rows) && (ed.csr.y += 1)
    end

    # Snap to end of line if we are further out
    rowlen = ed.csr.y < length(ed.rows)+1 ? length(ed.rows[ed.csr.y].chars)+1 : 1
    ed.csr.x > rowlen && (ed.csr.x = rowlen)
end

moveCursor(ed, key::Key) = moveCursor(ed, UInt32(key))



""" Scroll the screen based on the cursor position """
function scroll(ed::Editor)
    ed.csr.rx = 1
    if ed.csr.y <= length(ed.rows)
        ed.csr.rx = renderX(ed.rows[ed.csr.y], ed.csr.x)
    end

    # Vertical scrolling
    if ed.csr.y < ed.rowoff+1
        ed.rowoff = ed.csr.y-1
    end
    if ed.csr.y >= ed.rowoff+1 + ed.height
        ed.rowoff = ed.csr.y - ed.height
    end

    # Horizontal scrolling
    if ed.csr.rx < ed.coloff+1
        ed.coloff = ed.csr.rx
    end
    if ed.csr.rx >= ed.coloff+1 + ed.width
        ed.coloff = ed.csr.rx - ed.width
    end
end

function drawRows(ed::Editor, buf::IOBuffer)
    for y = 1:ed.height
        filerow = y + ed.rowoff
        y != 1 && write(buf, "\r\n")

        write(buf, "\x1b[K") # Clear line
        if filerow > length(ed.rows)
            if y == div(ed.height, 3) && ed.width > 40 && length(ed.rows) == 0
                msg = "Acorn Editor"
                padding = div(ed.width - length(msg), 2)
                if padding > 0
                    write(buf, "~")
                    padding -= 1
                end
                while (padding -= 1) > 0
                    write(buf, " ")
                end
                write(buf, msg)
            else
                write(buf, "~");
            end
        else
            len = length(ed.rows[filerow].render) - ed.coloff
            len = clamp(len, 0, ed.width)
            write(buf, ed.rows[filerow].render[1+ed.coloff : ed.coloff + len])
        end
    end
    # Write a newline to prepare for status bar
    write(buf, "\r\n");
end

function drawStatusBar(ed::Editor, buf::IOBuffer)
    write(buf, "\x1b[7m") # invert colors
    col = 1

    # left padding
    write(buf, ' ')
    col += 1

    # filename
    filestatus = string(ed.filename, ed.dirty ? " *" : "")

    for i = 1:min(div(ed.width,2), length(filestatus))
        write(buf, filestatus[i])
        col += 1
    end

    linenum = string(ed.csr.y)

    while col < ed.width - length(linenum)
        write(buf, ' ')
        col += 1
    end

    write(buf, linenum, ' ')

    write(buf, "\x1b[m") # uninvert colors

    # make line for message bar
    write(buf, "\r\n")
end

function drawStatusMessage(ed::Editor, buf::IOBuffer)
    write(buf, "\x1b[K")
    if time() - ed.status_time < 5.0
        write(buf, ed.statusmsg[1:min(ed.width, length(ed.statusmsg))])
    end
end

function setStatusMessage(ed::Editor, msg::String)
    ed.statusmsg = msg
    ed.status_time = time()
end

function refreshScreen(ed::Editor)

    # Update terminal size
    ed.height = Base.Terminals.height(ed.term) - 2 # status + msg bar = 2
    ed.width = Base.Terminals.width(ed.term)

    scroll(ed)

    buf = IOBuffer()

    write(buf, "\x1b[?25l") # ?25l: Hide cursor
    write(buf, "\x1b[H")    # H: Move cursor to top left

    drawRows(ed, buf)
    drawStatusBar(ed, buf)
    drawStatusMessage(ed, buf)

    @printf(buf, "\x1b[%d;%dH", ed.csr.y-ed.rowoff,
                                ed.csr.rx-ed.coloff)

    write(buf, "\x1b[?25h") # ?25h: Show cursor

    write(STDOUT, String(take!(buf)))
end

function editorPrompt(ed::Editor, prompt::String;
                      callback=nothing,
                      buf::String="",
                      showcursor::Bool=true) ::String
    while true
        statusmsg = string(prompt, buf)
        setStatusMessage(ed, string(prompt, buf))
        refreshScreen(ed)

        if showcursor
            # Position the cursor at the end of the line
            @printf(STDOUT, "\x1b[%d;%dH", 999, length(statusmsg)+1)
        end

        c = Char(readKey())

        if c == '\x1b'
            setStatusMessage(ed, "")
            callback != nothing && callback(ed, buf, c)
            return ""
        elseif c == '\r'
            if length(buf) != 0
                setStatusMessage(ed, "")
                callback != nothing && callback(ed, buf, c)
                return buf
            end
        elseif UInt32(c) == BACKSPACE && length(buf) > 0
            buf = buf[1:end-1]
        elseif !iscntrl(c) && UInt32(c) < 128
            buf = string(buf, c)
        end

        callback != nothing && callback(ed, buf, c)
    end
end




##############
## Keyboard ##
##############


function processKeypress(ed::Editor)
    c = readKey();

    if c == ctrl_key('p')
        runCommand(ed)
    elseif (c == ARROW_LEFT
            || c == ARROW_UP
            || c == ARROW_RIGHT
            || c == ARROW_DOWN)
        moveCursor(ed, c)
    elseif c == PAGE_UP || c == PAGE_DOWN
        lines = ed.height
        while (lines-=1) > 0
            moveCursor(ed, c == PAGE_UP ? ARROW_UP : ARROW_DOWN)
        end
    elseif c == HOME_KEY
        ed.csr.x = 0
    elseif c == END_KEY
        ed.csr.y < length(ed.rows) && (ed.csr.x = length(ed.rows[ed.csr.y].chars))
    elseif c == UInt32('\r')
        editorInsertNewline(ed)
    elseif c == BACKSPACE
        editorDelChar(ed)
    elseif c == DEL_KEY
        moveCursor(ed, ARROW_RIGHT)
        editorDelChar(ed)
    elseif c == ctrl_key('l')
        # Refresh screen
        return
    elseif c == UInt32('\x1b')
        return
    elseif iscntrl(Char(c)) && isKeyBound(Char(c))
        runCommand(ed, getKeyBinding(Char(c)))
    elseif c == UInt32('\t')
        editorInsertTab(ed)
    elseif !iscntrl(Char(c))
        editorInsertChar(ed, c)
    end

end


#####################
# Editor Operations #
#####################

function editorInsertChar(ed::Editor, c::UInt32)
    # The cursor is able to move beyond the last row
    ed.csr.y == length(ed.rows)+1 && appendRow(ed.rows, "")
    insertChar!(ed.rows[ed.csr.y], ed.csr.x, Char(c))
    ed.csr.x += 1
    ed.dirty = true
end

function editorInsertTab(ed::Editor)
    # The cursor is able to move beyond the last row
    ed.csr.y == length(ed.rows)+1 && appendRow(ed.rows, "")

    # Insert character(s) into the row data
    mv_fwd = insertTab!(ed.rows[ed.csr.y], ed.csr.x)

    ed.csr.x += mv_fwd

    ed.dirty = true
end


function editorDelChar(ed::Editor)
    ed.csr.y == length(ed.rows)+1 && return
    ed.csr.x == 1 && ed.csr.y == 1 && return

    if ed.csr.x > 1
        deleteChar!(ed.rows[ed.csr.y], ed.csr.x -1)
        ed.csr.x -= 1
        ed.dirty = true
    else
        # Move cursor to end of prev line
        ed.csr.x = 1+length(ed.rows[ed.csr.y-1].chars)
        appendRowString(ed.rows[ed.csr.y-1], ed.rows[ed.csr.y].chars)
        editorDelRow(ed, ed.csr.y)
        ed.csr.y -= 1
    end
end

function editorInsertRow(ed::Editor, i::Int, str::String)
    row = Row(str)
    update!(row)
    insert!(ed.rows, i, row)
end

function editorInsertNewline(ed::Editor)
    if ed.csr.x == 1
        editorInsertRow(ed, ed.csr.y, "")
    else
        row = ed.rows[ed.csr.y]
        before = row.chars[1:ed.csr.x-1]
        after = row.chars[ed.csr.x:end]
        editorInsertRow(ed, ed.csr.y + 1, after)
        row.chars = before
        update!(row)
    end
    ed.csr.y += 1
    ed.csr.x = 1
end

function editorDelRow(ed::Editor, i::Int)
    i < 1 || i > length(ed.rows) && return
    deleteat!(ed.rows, i)
    ed.dirty = true
end

function editorQuit(ed::Editor; force::Bool=false)
    if !force && ed.dirty
        setStatusMessage(ed,
            "File has unsaved changes. Save changes of use 'quit !' to quit anyway")
    else
        write(STDOUT, "\x1b[2J")
        write(STDOUT, "\x1b[H")
        ed.quit = true
        !isinteractive() && exit(0)
    end
end




############
# COMMANDS #
############


function runCommand(ed::Editor)
    cmd = editorPrompt(ed, "> ")
    runCommand(ed, strip(cmd))
end

function runCommand(ed::Editor, command_str::String)
    cmd_arr = split(command_str, ' ', limit=2)

    # Get the command
    cmd = strip(cmd_arr[1])

    # Blank, do nothing
    cmd == "" && return

    # Command must be a valid identifier
    if !Base.isidentifier(cmd)
        setStatusMessage(ed, "'$sym' is not a valid command name")
        return
    end

    cmd_sym = Symbol(cmd)

    # Get arguments if there are any
    args = ""
    if length(cmd_arr) > 1
        args = cmd_arr[2]
    end

    # If the command exists, run it
    if cmd_sym in keys(COMMANDS)
        # join(args): convert Substring to String
        runCommand(COMMANDS[cmd_sym], ed, join(args))
    else
        setStatusMessage(ed, "'$sym' is not a valid command")
    end
end

function runCommand(c::Command, ed::Editor, args::String)
    c.cmd(ed, args)
end
