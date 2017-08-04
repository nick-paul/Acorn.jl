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

```
Pkg.clone("https://github.com/nick-paul/Acorn.jl.git")
```

# Usage

From within the REPL:

```
using Acorn
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

Text selection, copy/paste, syntax highlighting, etc..
