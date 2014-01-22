#!/usr/bin/env python

import sys
import os
import re

def _open(f):
    if isinstance(f, str):
        try:
            return open(f)
        except:
            print >>sys.stderr, "Could not open file: %s" % f
            sys.exit(1)
    else:
        return f

def soft_newline(x):
    if isinstance(x, str) and x.endswith("\n"):
        x = x[:-1]
    print x

def pr(orig, x):
    if isinstance(x, str):
        soft_newline(x)
    else:
        try:
            for line in x:
                soft_newline(line)
        except TypeError as e: # not iterable
            if x is True:
                soft_newline(orig)
            elif x not in (None, False):
                soft_newline(str(x))

def do_whole(command, filename, f):
    """
    Defines: text (string)
             filename
    """
    text = f.read()
    pr(text, eval(command))

def do_lines(command, filename, f):
    """
    Defines: xs (array of lines)
             filename
    """
    xs = f.readlines()
    pr(xs, eval(command))

def do_line(command, filename, f):
    """
    Defines: x (current line)
             w (list of words)
             filename
    """
    for x in f.readlines():
        w = x.split()
        pr(x, eval(command))

def main(command, files):
    for filename in files:
        with _open(filename) as f:
            if re.findall(r'\btext\b', command):
                do_whole(command, filename, f)
            elif re.findall(r'\bxs\b', command):
                do_lines(command, filename, f)
            else:
                do_line(command, filename, f)

if __name__ == '__main__':
    command = sys.argv[1]
    files = sys.argv[2:]
    if files:
        main(command, files)
    else:
        main(command, [sys.stdin])

