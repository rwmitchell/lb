# lb: zsh addon

## About
Robust 'which' replacement combining output from other
standard commands to show more info about the program, function
or alias.

Source for scripts and functions can be optionally displayed.

This is my first contribution of personal use code.

## Usage
### Output from 'lb -h'

Find location of executable, function, or alias

	-C: colorize source
	-f: show 'file' output for executables
	-l: long ls output
	-v: show script and function source

## Requirements

The '-C' option uses 'colorize_cat' from the 'colorize' plugin found in OMZ.

Additional information about the type of file is displayed using the unix
'file' command and assumed to be present.

## Installation
Copy or ln 'lb' to your location for loading autoload zsh tools.
