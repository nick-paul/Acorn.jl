# Acorn.jl

[![Build Status](https://travis-ci.org/nick-paul/Acorn.jl.svg?branch=master)](https://travis-ci.org/nick-paul/Acorn.jl)

[![Coverage Status](https://coveralls.io/repos/nick-paul/Acorn.jl/badge.svg?branch=master&service=github)](https://coveralls.io/github/nick-paul/Acorn.jl?branch=master)

[![codecov.io](http://codecov.io/github/nick-paul/Acorn.jl/coverage.svg?branch=master)](http://codecov.io/github/nick-paul/Acorn.jl?branch=master)

A pure julia text editor

![Basic Demo](http://npaul.co/files/Acorn_basic_demo.gif)

# Features

![Commands](http://npaul.co/files/Acorn_commands_demo.gif)

  - Use in REPL or from command line
  - Commands like `find`, `help`, `save` + easy to create your own.
  - Customizable key bindings and settings


# Installing

```julia
Pkg.clone("https://github.com/nick-paul/Acorn.jl.git")
```

# Usage

From within the REPL:

```
julia> using Acorn
julia> acorn("filename")
```

From the command line

```
$ julia -E "using Acorn;acorn()" filename
```

Use an alias to make command line easier:

```
$ alias acornjl='julia -E "using Acorn;acorn()"'
$ acornjl filename
```

# Commands

Press `Ctrl-P` to enter command mode. Type 'help COMMAND' for more information on that command.

*arguments in `[brackets]` are optional*

  - `help [CMD]`: display help information for CMD
  - `quit`: quit the editor
  - `open FILE`: open a file, create a new one if needed
  - `save [FILE]`: save the file, if a new filename is provided, save as that name
  - `find [STR]`: start interactive find. if STR is provided, start interactive search with STR
  - `echo STR`: display STR as a message
  - `set param_name param`: set parameter `param_name` to `param`. ex: `set tab_stop 4`
  - `bind char command`: bind `Ctrl-(char)` to the command `command`. ex: `bind s save`, `bind h echo Hello world!`


# Customization / Contributing

## Commands

Commands are easy to create and allow for greater editor usability. To create your own command, create a julia file in the `cmds` folder and name it after your command. Then include your file in the Acorn module. Below is an example definition of the command `sample`. For more examples, see the `cmds/` folder.


### `cmds/sample.jl`

```julia

# The command must have the signature
#   function(::Editor, ::String)
function sampleCommand(ed::Editor, args::String)
    # Perform operation here

    # If you need to store state variables use ed.params
    # ed.params[:YOUR CMD NAME][VAR NAME]
    ed.params[:sample][:var_name] = some_val

    # If you need to request input from the user:
    editorPrompt(ed, "Enter your name: ",
            callback=sampleCallback     # Callback fucntion: function(ed::Editor, buf::String, key::Char
            buf="",             # Starting point for the input buffer. This text is
                                #   'automatically' typed into the input when the
                                #   prompt loads
            showcursor=true)    # Move the cursor to the prompt

end

# Optional: If you request input from the user and need a
#   callback function, use the following format:
function sampleCallback(ed::Editor, buf::String, key::Char)
    # Perform callback action here...
end


# Call `addCommand` to add
addCommand(:sample,                         # The command name
            sampleCommand,                  # The command function
            help="description of sample")   # Displayed when user runs 'help sample'
```

### `Acorn.jl`

Include your command here

```julia
# Load commands
#...
include("cmds/save.jl")
include("cmds/find.jl")
include("cmds/sample.jl") # Add this line
#...
```

## Features

Text selection, copy/paste, syntax highlighting, etc. have not yet been implemented. I will try to keep up with issues and pull requests regarding features so feel free to add whatever you like to the editor.

## Bug Fixes / Compatability

Acorn has not been tested on OSX and currently has compatability issues with Windows. If you run into any problems on your platform feel free to patch it and send a pull request.

If you experience any bugs, please submit an issue or patch it and send a pull request.
