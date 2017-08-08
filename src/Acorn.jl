module Acorn

include("terminal.jl")

# Configuration submodule
include("EditorConfig.jl")
using .EditorConfig

include("row.jl")
include("cmds/Command.jl")
include("editor.jl")


# Load commands
include("cmds/open.jl")
include("cmds/save.jl")
include("cmds/quit.jl")
include("cmds/find.jl")
include("cmds/help.jl")
include("cmds/bind.jl")
include("cmds/set.jl")
include("cmds/echo.jl")

function acorn(filename::String; rel::Bool=true)
    ed = Editor()

    #rel && (filename = abspath(filename))

    editorOpen(ed, filename)

    setStatusMessage(ed, "HELP: ctrl-p: command mode | ctrl-q: quit | ctrl-s: save")

    Base.Terminals.raw!(ed.term, true)

    try
        while !ed.quit
            refreshScreen(ed)
            processKeypress(ed)
        end
    catch ex
        editorQuit(ed, force=true)
        throw(ex)
    end

    Base.Terminals.raw!(ed.term, false)

    return nothing
end

function acorn()
    # If a file is given, open it
    if length(ARGS) > 0
        filename = ARGS[1]
        acorn(filename, rel=false)
    end
end

export
    acorn

end # module
