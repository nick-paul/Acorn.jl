struct Command
    name::Symbol
    help::String
    cmd::Function
end

const COMMANDS = Dict{Symbol, Command}()

function addCommand(name::Symbol, cmd::Function; help::String="")
    COMMANDS[name] = Command(name, help, cmd)
end
