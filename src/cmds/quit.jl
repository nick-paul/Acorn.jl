function commandQuit(ed::Editor, args::String)
    editorQuit(ed, force=strip(args) == "!")
end

addCommand(:quit, commandQuit,
           help="quit [!]: quit acorn. run 'quit !' to force quit")
