# Acorn.jl

[![Build Status](https://travis-ci.org/nick-paul/Acorn.jl.svg?branch=master)](https://travis-ci.org/nick-paul/Acorn.jl)

[![Coverage Status](https://coveralls.io/repos/nick-paul/Acorn.jl/badge.svg?branch=master&service=github)](https://coveralls.io/github/nick-paul/Acorn.jl?branch=master)

[![codecov.io](http://codecov.io/github/nick-paul/Acorn.jl/coverage.svg?branch=master)](http://codecov.io/github/nick-paul/Acorn.jl?branch=master)

A pure julia text editor

# Features

## Use in REPL or from command line



## Commands

## Customizable key bindings to commands


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
  - `bind char command`: bind `Ctrl-(char)` to the command `command`. ex: `bind s save`, `bind h echo Hello world!"

