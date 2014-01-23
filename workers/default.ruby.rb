#!/usr/bin/env ruby

# Extensions to the string class
class String
  # Bold, color, etc. on terminal
  def sgr(code)
    if self.match(/\n$/)
      # If highlighting a whole line, end it before \n
      "\x1B[#{code}m#{self[0..-2]}\x1B[0m\n"
    else
      "\x1B[#{code}m#{self}\x1B[0m"
    end
  end
  def bold
    sgr(1)
  end
  %w(black red green yellow blue magenta cyan white).each_with_index do |method, i|
    define_method(method) { sgr(30 + i) }
  end
  def match?(pattern)
    if match(pattern)
      true
    else
      false
    end
  end
end

def pr(orig, result)
  if result.kind_of?(Array)
    result.each do |z| puts z end
  elsif result === true
    puts orig
  elsif result
    puts result
  end
end

def _open(f)
  if f.kind_of?(String)
    begin
      File.open(f)
    rescue
      $stderr.puts "#{$0}: Could not open file '#{f}'"
      exit 1
    end
  else
    f
  end
end

def do_whole(command, filename, file)
  # Defines: text (string)
  #          xs (array of lines)
  #          filename
  text = file.read
  xs = text.split("\n")
  pr(text, eval(command))
end

def do_line(command, filename, file)
  # Defines: x (current line)
  #          w (list of words)
  #          filename
  file.each do |x|
    w = x.split
    pr(x, eval(command))
  end
end

def main(command, files)
  files.each do |filename|
    file = _open(filename)
    if command.match(/\btext\b/) or command.match(/\bxs\b/)
      do_whole(command, filename, file)
    else
      do_line(command, filename, file)
    end
  end
end

command, *args = ARGV

if !command or command =~ /-?-?help/
  puts <<EOF
adhoc --ruby <command> [file] ...
How to use:

The variable 'filename' always contains the name of the current file
(or a handle to stdin, if no files were provided).

If <command> contains a variable named 'text' or 'xs':
  * <command> will be executed only once
  * Variable 'text' contains the whole file as a string.
  * Variable 'xs' contains a list of lines.
  * Result of 'eval(command)' is printed:
    * string?       => printed on a line.
    * array?        => each element printed on a line.
    * true          => 'text' is printed.
    * false or nil  => nothing is printed.

Otherwise:
  * <command> will be executed once per line
  * Variable 'x' contains the current line
  * Variable 'w' contains a list of words (for convenience)
  * Result of 'eval(command)' is printed:
    * string?       => printed on a line.
    * array?        => each element printed on a line.
    * true          => 'x' is printed.
    * false or nil  => nothing is printed.

EXAMPLES:
  adhoc --ruby 'x.gsub(//)'
  adhoc --ruby 
  adhoc --ruby 
  adhoc --ruby 
  adhoc --ruby 
  adhoc --ruby 
  adhoc --ruby 

EOF

elsif args.empty?
  main(command, [STDIN])
else
  main(command, args)
end

