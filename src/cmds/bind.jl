function commandBind(ed::Editor, args::String)
    arg_arr = strip.(split(args, ' ', limit=2))

    if length(arg_arr) != 2
        setStatusMessage(ed, "bind: command requires two arguments")
        return
    elseif !( length(arg_arr[1]) == 1 && isalpha(arg_arr[1][1]) )
        setStatusMessage(ed, "bind: first arg must be a letter")
        return
    end

    key = lowercase(arg_arr[1][1])
    command = join(arg_arr[2])

    # If command is '~', unbind the key
    if command == "~"
        rmKeyBinding(key)
    else
        setKeyBinding(key, join(arg_arr[2]))
    end

end

addCommand(:bind, commandBind,
            help="bind <C> <CMD>: bind ctrl-<C> to command <CMD>. <CMD> = ~, unbind")
