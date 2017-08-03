function commandSave(ed::Editor, args::String)
    editorSave(ed, args)
end

addCommand(:save, commandSave,
           help="save: save the file")
