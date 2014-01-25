#!/usr/bin/env python

import sys
import os
import re

def soft_newline(x):
    if isinstance(x, str) and x.endswith("\n"):
        x = x[:-1]
    print x

def pr(orig, x, do):
    if isinstance(x, str):
        do(x)
    else:
        try:
            for line in x:
                do(line)
        except TypeError as e: # not iterable
            if x is True:
                do(orig)
            elif x not in (None, False):
                do(x)

def _open(f):
    if isinstance(f, str):
        try:
            return open(f)
        except:
            print >>sys.stderr, "Could not open file: %s" % f
            sys.exit(1)
    else:
        return f

def do_line(command, filename, f, do):
    """
    Defines: x (current line)
             w (list of words)
             filename
    """
    for line in f.readlines():
        x = line
        w = x.split()
        pr(line, eval(command), do)

def main(line_command, lines_commands, files):
    if not line_command:
        line_command = 'line'
    if not lines_commands:
        for filename in files:
            with _open(filename) as f:
                do_line(line_command, filename, f, soft_newline)
    else:
        lines = []
        for filename in files:
            with _open(filename) as f:
                do_line(line_command, filename, f, lines.append)
        orig = None
        for cmd in lines_commands:
            orig = lines
            try:
                text = "".join(lines)
            except TypeError:
                text = None
            lines = eval(cmd)
        pr(orig, lines, soft_newline)



if __name__ == '__main__':
    line_command = None
    lines_commands = []
    args = []
    for arg in sys.argv[1:]:
        if arg.startswith(":"):
            lines_commands.append(arg[1:])
        elif arg.startswith("\:"):
            args.append(arg[1:])
        elif not lines_commands and line_command is None:
            line_command = arg
        else:
            args.append(arg)
    if not args:
        args = [sys.stdin]

    if ((not line_command or line_command in ["help", "-help", "--help"])
        and not lines_commands):
        print """
adhoc --py <command> [:<command>] ... [file] ...

<command> is run once for every line of every file using

    eval(<command>)

The current line is placed in the `line` variable.

If the result is...
    * string?       => printed on a line.
    * array?        => each element printed on a line.
    * True          => 'text' is printed.
    * False or None => nothing is printed.

If there is at least one :<command>, then the results are not printed
but are instead accumulated in a list called `lines`. Each :<command>
is run once using

    eval(<command>)

The variable `lines` contains the list of lines; the variable `text`
contains the result of `"".join(lines)`.

Note: the variable 'filename' contains the name of the file (or a
handle to stdin, if no files were provided).

EXAMPLES:
  # Print the first whitespace-separated field of each line
  adhoc --py 'line.split()[1]'
  adhoc --py 'line.split(":")[1]'  # first colon-separated field

  # Sort numerically by fifth field
  adhoc --py ':sorted(lines, key = lambda k: int(k.split()[4]))'

  # Select lines that contain numbers
  adhoc --py 're.findall(r"\d+", line) and line'

  # Print and sort all different words of a file
  adhoc --py 'sorted(set(text.split()))'

  # Word count
  adhoc --py ':len(text.split())'
  adhoc --py 'len(line.split())' ':sum(lines)'


Imported packages:
    re, sys, os
"""
    else:
        main(line_command, lines_commands, args)

