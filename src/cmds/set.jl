function commandSet(ed::Editor, args::String)
    arg_arr = strip.(split(args, ' '))

    # Initial checks
    if length(arg_arr) != 2
        setStatusMessage(ed, "set: command requires two arguments")
        return
    elseif !Base.isidentifier(arg_arr[1])
        setStatusMessage(ed, "set: $(arg_arr[1]) is not a valid command name")
        return
    end

    sym = Symbol(arg_arr[1])

    # Check if it is a valid parameter
    if !configIsParam(sym)
        setStatusMessage(ed, "set: '$sym' is not a valid parameter name")
        return
    end

    # Attempt to assign the parameter
    try
        val = parse(arg_arr[2])
        configSet(sym, val)
    catch Exception
        setStatusMessage(ed, "set: invalid argument for $sym '$(arg_arr[2])'")
    end

    for row in ed.rows
        update!(row)
    end
    refreshScreen(ed)
end

addCommand(:set, commandSet, 
           help="set <param> <value>: set the given parameter to a value")
