require 'date'
require 'byebug'

module KeyPress

  def header_string
      return "" if self.class == PairProgrammingGitConsole
      pwd = `pwd`.chomp
      @git_branch = `git rev-parse --abbrev-ref HEAD`.chomp
      next_switch_time = next_switch_time_calc
      if @paused
        next_switch_time = "paused: #{next_switch_time}"
      else

      end
      return "|-#{@navigator.name}:~#{pwd}(#{@git_branch}) #{next_switch_time} -|$ "
  end

  def next_switch_time_calc
    timeleft = (@next_switch_time - Time.now).round
    unless timeleft < 0
      seconds_left = timeleft % 60
      seconds_left = (seconds_left < 10 ? "0#{seconds_left}" : seconds_left)
      "#{timeleft / 60}:#{seconds_left}"
    else
      "Time to Switch"
    end
  end

  def read_char
    STDIN.echo = false
    STDIN.raw!

    input = STDIN.getc.chr

    if input == "\e" then
      input << STDIN.read_nonblock(3) rescue nil
      input << STDIN.read_nonblock(2) rescue nil
    end
  ensure
    STDIN.echo = true
    STDIN.cooked!

    return input
  end

  def handle_key_press
    c = read_char
    @last_keypress = Time.now
    if @responding
      return
    end
    case c
    when " "
      if @strings[@strings_index].length == 0 || @right_index == -1
        @strings[@strings_index]  << " "
      else
        split_index = @right_index + 1
        @strings[@strings_index] = @strings[@strings_index][0...split_index] + " " + @strings[@strings_index][split_index..-1]
      end
      print "\r"
      print header_string
      print @strings[@strings_index]
      print "\r"
      print header_string
      print @strings[@strings_index][0..@right_index]
    when "\t"
      # puts "T"
    when "\r"
      @right_index = -1
      command = @strings[@strings_index]
      if @strings[@strings_index].length > 0 && @strings_index == -1
          @strings << ""
      end
      if @strings.length > 100
          @strings = @strings.drop(@strings.length - 100) # .shift?
      end
      puts
      @strings_index = -1
      return command
    when "\n"
      # puts "LINE FEED"
    when "\e"
      # puts "ESCAPE"
    when "\e[A" #Up Arrow
      @right_index = -1
      return if @strings_index <= -(@strings.length)
      clear_lines
      print " " * (header_string.length + @strings[@strings_index].length) + " "
      clear_lines
      print header_string
      @strings_index -= 1
      print @strings[@strings_index]
    when "\e[B" #Down Arrow
      @right_index = -1
      return if @strings_index == -1
      clear_lines
      print " " * (header_string.length + @strings[@strings_index].length) + " "
      clear_lines
      print header_string
      @strings_index += 1
      print @strings[@strings_index]
    when "\e[C" #Right arrow
      @right_index += 1 if @right_index < -1
      @right_index = -1
      print "\r"
      print header_string
      print @strings[@strings_index][0..@right_index]
    when "\e[D" #Left Arrow
      @right_index -= 1 unless @right_index <= -(@strings[@strings_index].length)
      print "\r"
      print header_string
      print @strings[@strings_index][0..@right_index]
    when "\177"
      print "\r"
      print " " * ((header_string + @strings[@strings_index]).length)
      clear_lines
      print header_string
      if @strings[@strings_index].length == 0 || @right_index == -1
        @strings[@strings_index] = @strings[@strings_index][0..-2]
      else
        split_index = @right_index + 1
        @strings[@strings_index] = @strings[@strings_index][0...@right_index] + @strings[@strings_index][split_index..-1]
      end
      clear_lines
      print header_string
      print @strings[@strings_index]
      clear_lines
      print header_string
      print @strings[@strings_index][0..@right_index]
    when "\004"
      # puts "DELETE"
    when "\e[3~"
      # puts "ALTERNATE DELETE"
    when "\u0003"
      exit 0
    when /^.$/
      if @strings[@strings_index].length == 0 || @right_index == -1
        @strings[@strings_index]  << c
      else
        split_index = @right_index + 1
        @strings[@strings_index] = @strings[@strings_index][0...split_index] + c + @strings[@strings_index][split_index..-1]
      end
      clear_lines
      print header_string
      print @strings[@strings_index]
      clear_lines
      print header_string
      print @strings[@strings_index][0..@right_index]
    end
  end

  def clear_lines
      print "\b" * ((header_string + @strings[@strings_index]).length)
      print "\r"
  end

  def input_prompt
    length = @strings.length
    key_press = nil
    until key_press
      key_press = handle_key_press
    end
    key_press
  end
end
