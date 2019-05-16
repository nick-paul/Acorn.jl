module EditorConfig


###############
## Parameter ##
###############

struct Parameter{T}
    value::T
    validate::Union{Function, Nothing}
    desc::String # Used when calling help <param name>
end

validate(p::Parameter) = p.validate == nothing ? true : p.validate(p.value)

function set(p::Parameter, x)
    old_val = p.value

    # Correct type?
    try
        p.value = x
    catch Exception
        p.value = old_val
        throw(ArgumentError("Invalid parameter assignment: $sym, $x"))
    end

    # Valid?
    if !validate(p)
        p.value = old_val
        throw(ArgumentError("Invalid parameter assignmnt: $sym, $x"))
    end
end




############
## CONFIG ##
############

const CONFIG = Dict{Symbol, Parameter}()



function configSet(sym::Symbol, x)
    # Check if parameter exists
    if !(sym in keys(CONFIG))
        throw(ArgumentError("No parameter named $sym"))
    end

    p = CONFIG[sym]
    set(p, x)

    CONFIG[sym] = p
end

configGet(sym::Symbol) = CONFIG[sym].value
configDesc(sym::Symbol) = CONFIG[sym].desc
configIsParam(sym::Symbol) = sym in keys(CONFIG)





##################
## KEY BINDINGS ##
##################


const KEY_BINDINGS = Dict{UInt32, String}()

"""Remove a keybinding"""
function rmKeyBinding(c::Char)
    delete!(KEY_BINDINGS, UInt32(c) & 0x1f)
end

"""Set a keybinding"""
function setKeyBinding(c::Char, s::String)
    KEY_BINDINGS[UInt32(c) & 0x1f] = s
end

"""Get command from keybinding"""
function getKeyBinding(c::Char) ::String
    get(KEY_BINDINGS, UInt32(c) & 0x1f, "")
end

"""Return true if the given key is bound to a command"""
isKeyBound(c::Char) = (UInt32(c) & 0x1f) in keys(KEY_BINDINGS)




########################
## DEFAULT PARAMETERS ##
########################

CONFIG[:tab_stop] = Parameter{Int}(4, n-> n > 0 && n <= 16, "visual size of a tab in number of spaces")
CONFIG[:expandtab] = Parameter{Bool}(false, nothing, "if true, use spaces instead of tabs when pressing <tab>")
CONFIG[:status_fullpath] = Parameter{Bool}(false, nothing, "show full path to current file")

##########################
## DEFAULT KEY BINDINGS ##
##########################

setKeyBinding('s', "save")
setKeyBinding('o', "open")
setKeyBinding('f', "find")
setKeyBinding('q', "quit")


export
    configGet,
    configSet,
    configIsParam,
    configDesc,
    rmKeyBinding,
    setKeyBinding,
    getKeyBinding,
    isKeyBound

end #module
