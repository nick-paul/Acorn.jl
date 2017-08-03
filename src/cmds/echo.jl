function commandEcho(ed::Editor, args::String)
    setStatusMessage(ed, args)
end

addCommand(:echo, commandEcho,
           help="echo <msg>: set the status message to <msg>")
