function commandOpen(ed::Editor, args::String)
    if args == ""
        editorOpen(ed)
    else 
        editorOpen(ed, args)
    end
end

addCommand(:open, commandOpen,
           help="open: open a file")
