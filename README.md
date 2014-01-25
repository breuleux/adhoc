
`adhoc`: ad hoc commands
========================

Picture the following situation:

* You want to do something simple, like printing out the second
  comma-separated field of each line of a file.

* You don't know or remember how to do it on the command line. Maybe
  you don't know `cut` exists or don't know what the flags are. Or
  maybe there is no easy solution at all!

* You know how to do it in some programming language that you are
  proficient in (but it requires a good deal of boilerplate).

`adhoc` is a simple dispatcher towards scripts in various languages
that contain the proper boilerplate. It is used like this:

    adhoc --lang <command> [:<command>] [file] ...

The `<command>` is a code snippet to execute on every line of each
file. The `:<command>` is an optional code snippet to execute on the
complete list of transformed lines produced by the `<command>`.

For instance, if you wanted to extract the first word of each line and
print all unique occurrences (sorted), you could do:

    adhoc --rb split[0] :uniq.sort file.txt
    adhoc --py 'line.split()[0]' ':sorted(set(lines))' file.txt

The point of having multiple languages is to make sure as many people
as possible have access to a language they are already familiar with
and to promote code reuse: if you have some helper functions that you
would like to use with adhoc and that your language is supported, you
can add them very easily. The same goes for external libraries and
packages.


Languages available
-------------------

* Ruby (**default**): `--ruby`, `--rb`
* Python: `--python`, `--py`

These are the two I have implemented myself. Feel free to add more and
do pull requests!


Installing
----------

You will need Ruby to be installed, in addition to the language that
you want to use.

* Copy, move or link the `scripts` directory into `$HOME/.adhoc`

  * You can also set the `$ADHOCPATH` environment variable to whatever
    path the scripts are in.

* Put `adhoc` somewhere accessible from your `$PATH`.

* Use it!

The default language is Ruby. If you prefer another language, simply
move `~/.adhoc/default.ruby.rb` to `ruby.rb` and `yourlang.yl` into
`default.yourlang.yl`. For instance, if you want Python by default,
you must have the Python script in `~/.adhoc/default.python.py`. If
there is more than one default language, `adhoc` will give an error
message.


Documentation
-------------

Type `adhoc --lang` to get help about the particular language. The
interface may differ from a language to another.


Extending
---------

The `adhoc` dispatcher is ridiculously simple: if you write `adhoc
--lang args ...` it will look in `~/.adhoc` or `$ADHOCPATH` for a file
with a `lang` part in its name, then it will call it with the rest of
the arguments.

It is then your job to implement the interface:

* Any argument which starts with a colon is a *global command*.

* If the first argument is not a global command, then it is the *line
  command*.

* Other arguments are file names. If there are none then we take input
  from standard in.

The *line command* must be executed on each line. If there are no
global commands, then the result of the command must be printed,
otherwise it is accumulated in a list. If there is no line command,
assume the identity function on each line.

The *global command* is executed on that list, accumulated from all
files. Its result is printed. You don't have to accept more than one
global command, but if you do, they should be executed one after the
other, each on the result of the previous.

Note that you can freely edit the files for existing languages to add
useful functionality. For instance, you could import parsing
libraries, extend built-in types, etc.



Examples
--------

### Ruby

Ruby is the default language because of its terseness, so unless you
change the default, you don't have to write `--rb`.

The Ruby engine evaluates the line command in the context of the line
with `instance_eval`, which means you can use string methods
unqualified. Same for global commands and the list of lines.

    # Print the first whitespace-separated field of each line
    adhoc --rb line.split[1]
    adhoc --rb split[1]       # line is the implicit subject, so you can leave it out
    adhoc --rb split(":")[1]  # first colon-separated field
  
    # Sort numerically by fifth field
    adhoc --rb ':sort_by{|x| x.split[4].to_i}'
  
    # Select lines that contain numbers
    adhoc --rb 'match?(/\d+/)'
    adhoc --rb 'line if match(/\d+/)'
    adhoc --rb ':select{|x| x.match(/\d+/)}'
  
    # Print and sort all different words of a file
    adhoc --rb split :sort.uniq
  
    # Word count
    adhoc --rb :join.split.count
    adhoc --rb split.count :sum


### Python

Python puts the line in the `line` variable and the list of lines in
the `lines` variable.

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


