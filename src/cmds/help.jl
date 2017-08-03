function commandHelp(ed::Editor, args::String)
    if args == ""
        setStatusMessage(ed, "Type help <command> for command specific help")
        return
    end

    if !Base.isidentifier(args)
        setStatusMessage(ed, "help: '$args' is not a valid command name")
        return
    end

    sym = Symbol(args)

    # Try getting help information from commands and params
    helptext = ""

    if configIsParam(sym)
        helptext = configDesc(sym)
    elseif sym in keys(COMMANDS)
        helptext = COMMANDS[sym].help
    end

    if helptext == ""
        setStatusMessage(ed, "No help documents for '$args'")
    else
        setStatusMessage(ed, helptext)
    end
end

addCommand(:help, commandHelp,
    help="Type help <command> for command specific help")
