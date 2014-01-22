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
  elsif result.kind_of?(TrueClass)
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

def do_whole(command, file)
  # Defines: all (string)
  #          filename
  all = file.read
  pr(all, eval(command))
end

def do_lines(command, file)
  # Defines: xs (array of lines)
  #          filename
  xs = file.readlines
  pr(xs, eval(command))
end

def do_line(command, file)
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
    if command.match(/\ball\b/)
      do_whole(command, file)
    elsif command.match(/\bxs\b/)
      do_lines(command, file)
    else
      do_line(command, file)
    end
  end
end

command, *args = ARGV
if args.empty?
  main(command, [STDIN])
else
  main(command, args)
end

