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

class Array
  def sum
    inject{|sum,x| sum + x }
  end
end

def pr(orig, result, &acc)
  if result.kind_of?(Array)
    result.each do |z| acc.call(z) end
  elsif result === true
    acc.call(orig)
  elsif result
    acc.call(result)
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

def do_line(command, filename, file, &acc)
  # Defines: line (current line)
  #          filename
  file.each do |line|
    pr(line, line.instance_eval(command), &acc)
  end
end

def main(line_command, lines_commands, files)
  line_command ||= 'self'
  if lines_commands.empty?
    files.each do |filename|
      file = _open(filename)
      do_line(line_command, filename, file) do |x| puts x end
    end
  else
    lines = []
    files.each do |filename|
      file = _open(filename)
      do_line(line_command, filename, file) do |x| lines.push(x) end
    end
    orig = nil
    lines_commands.each do |cmd|
      orig = lines
      lines = lines.instance_eval(cmd)
    end
    pr(orig, lines) do |x| puts x end
  end
end

line_command = nil
lines_commands = []
args = []

for arg in ARGV
  if arg =~ /^:.*/
    lines_commands.push(arg[1..-1])
  elsif arg =~ /^\\:.*/
    args.push(arg[1..-1])
  elsif lines_commands.empty? and line_command === nil
    line_command = arg
  else
    args.push(arg)
  end
end

args = [STDIN] if args.empty?

if (!line_command or line_command =~ /-?-?help/) and lines_commands.empty?

    puts <<EOF
adhoc --ruby <command> [:<command>] ... [file] ...

<command> is run once for every line of every file using

    line.instance_eval(<command>)

The `line` variable is available, but you can also use String methods
unqualified.

If the result is...
    * string?       => printed on a line.
    * array?        => each element printed on a line.
    * true          => 'text' is printed.
    * false or nil  => nothing is printed.

If there is at least one :<command>, then the results are not printed
but are instead accumulated in a list called `lines`. Each :<command>
is run once using

    lines.instance_eval(<command>)

Note: the variable 'filename' contains the name of the file (or a
handle to stdin, if no files were provided).

EXAMPLES:
  # Print the first whitespace-separated field of each line
  adhoc --ruby line.split[1]
  adhoc --ruby split[1]       # line is the implicit subject, so you can leave it out
  adhoc --ruby split(":")[1]  # first colon-separated field

  # Sort numerically by fifth field
  adhoc --ruby ':sort_by{|x| x.split[4].to_i}'

  # Select lines that contain numbers
  adhoc --ruby 'line if match?(/\d+/)'
  adhoc --ruby ':select{|x| x.match?(/\d+/)}'

  # Print and sort all different words of a file
  adhoc --ruby split :sort.uniq

  # Word count
  adhoc --ruby :join.split.count
  adhoc --ruby split.count :sum

EXTENSIONS
  Extra methods for String class:
    bold, black, red, green, yellow, blue, magenta, cyan, white
  Extra methods for Array class:
    sum

EOF

else
  main(line_command, lines_commands, args)
end


