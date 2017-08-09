import Acorn.EditorConfig

ed = Acorn.Editor()

Acorn.commandBind(ed, "h help")
@test EditorConfig.isKeyBound('h') == true
@test EditorConfig.getKeyBinding('h') == "help"

Acorn.commandBind(ed, "h ~")
@test EditorConfig.isKeyBound('h') == false

EditorConfig.rmKeyBinding('c')
Acorn.commandBind(ed, "c")
@test EditorConfig.isKeyBound('c') == false

Acorn.commandBind(ed, "a echo a b c d")
@test EditorConfig.isKeyBound('a') == true
