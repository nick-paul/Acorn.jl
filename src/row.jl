#############
#    ROW    #
#############

"""Holds file true data and render data"""
mutable struct Row
    "file data, a row of text"
    chars::String

    "a row of text as rendered on screen"
    render::String
end

Row(s::String) = Row(s, "")

"""Update the `render` string using the `chars` string"""
function update!(row::Row)
    # Count the number of tabs
    tabs = 0
    for c in row.chars
        c == '\t' && (tabs += 1)
    end

    # Allocate an array of characters
    updated = Array{Char, 1}(undef, length(row.chars) + tabs*(configGet(:tab_stop)-1))

    # copy the characters into the updated array
    idx = 1
    for i in 1:length(row.chars)

        # replace tabs with spaces
        if row.chars[i] == '\t'
        updated[idx] = ' '
        idx += 1
        while idx % configGet(:tab_stop) != 0;
            updated[idx] = ' ';
            idx += 1
            end
        else
        updated[idx] = row.chars[i]
        idx += 1
        end

    end

    row.render = join(updated[1:idx-1])
end

"""Convert a cursor position in the document to a rendered cursor position"""
function renderX(row::Row, cx::Int)
    rx = 1
    for i in 1:cx-1
        # If there is a tab, move the cursor forward to the tab stop
        if row.chars[i] == '\t'
            rx += (configGet(:tab_stop) - 1) - (rx % configGet(:tab_stop))
        end
        rx += 1
        end
    rx
end


"""opposite of renderX: Convert a render position to a chars position"""
function charX(row::Row, rx::Int)
    cur_rx = 1
    for cx = 1:length(row.chars)
        if row.chars[cx] == '\t'
            cur_rx += (configGet(:tab_stop) - 1) - (cur_rx % configGet(:tab_stop))
        end
        cur_rx += 1

        cur_rx > rx && return cx
    end
    cx
end


"""Insert a char or string into a string"""
function insert(s::String, i::Int, c::Union{Char,String})
    if s == ""
        string(c)
    else
        string(s[1:i-1], c, s[i:end])
    end
end

"""Delete char from string"""
function delete(s::String, i::Int)
    i < 1 || i > length(s) && return s
    string(s[1:i-1], s[i+1:end])
end

"""Insert a char into the row at a given location"""
function insertChar!(row::Row, i::Int, c::Char)
    row.chars = insert(row.chars, i, c)
    update!(row)
end

"""Insert a tab into the row at a given location. Return the number of chars inserted"""
function insertTab!(row::Row, i::Int)
    num_chars = 1
    t = '\t'

    # If we are using spaces, move ahead more
    if configGet(:expandtab)
        num_chars = configGet(:tab_stop) - (i % configGet(:tab_stop))
        t = repeat(" ", num_chars)
    end

    row.chars = insert(row.chars, i, t)
    update!(row)

     # Used for positioning the cursor
    return num_chars
end


"""Delete char from row"""
function deleteChar!(row::Row, i::Int)
    row.chars = delete(row.chars, i)
    update!(row)
end

"""
Add a row to the end of the document
initialize the row with the given string
"""
function appendRowString(row::Row, str::String)
    row.chars = string(row.chars, str)
    update!(row)
end



########
# ROWS #
########

"""type alias for Array{Row, 1}"""
Rows = Array{Row, 1}

"""delete all rows from a Rows"""
function clearRows(rows::Rows)
    while length(rows) > 0
        pop!(rows)
    end
end


"""Add a row to the end of the document"""
function appendRow(rows::Rows, s::String)
    row = Row(s)
    update!(row)
    push!(rows, row)
end


"""Convert all ROW data to a single string"""
function rowsToString(rows::Rows)
    join(map(row -> row.chars, rows), '\n')
end
