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
                do(str(x))

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
HELP
"""
    else:
        main(line_command, lines_commands, args)

