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
      if @current_string.length == 0 || @right_index == -1
        @current_string  << " "
      else
        split_index = @right_index + 1
        @current_string = @current_string[0...split_index] + " " + @current_string[split_index..-1]
      end
      print "\r"
      print header_string
      print @current_string
      print "\r"
      print header_string
      print @current_substring
    when "\t"
      # puts "T"
    when "\r"
      @right_index = -1
      command = @current_string
      if @current_string.length > 0 && @strings_index == -1
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
      print " " * (header_string.length + @current_string.length) + " "
      clear_lines
      print header_string
      @strings_index -= 1
      print @current_string
    when "\e[B" #Down Arrow
      @right_index = -1
      return if @strings_index == -1
      clear_lines
      print " " * (header_string.length + @current_string.length) + " "
      clear_lines
      print header_string
      @strings_index += 1
      print @current_string
    when "\e[C" #Right arrow
      @right_index += 1 if @right_index < -1
      @right_index = -1
      print "\r"
      print header_string
      print @current_substring
    when "\e[D" #Left Arrow
      @right_index -= 1 unless @right_index <= -(@current_string.length)
      print "\r"
      print header_string
      print @current_substring
    when "\177"
      print "\r"
      print " " * ((header_string + @current_string).length)
      clear_lines
      print header_string
      if @current_string.length == 0 || @right_index == -1
        @current_string = @current_string[0..-2]
      else
        split_index = @right_index + 1
        @current_string = @current_string[0...@right_index] + @current_string[split_index..-1]
      end
      clear_lines
      print header_string
      print @current_string
      clear_lines
      print header_string
      print @current_substring
    when "\004"
      # puts "DELETE"
    when "\e[3~"
      # puts "ALTERNATE DELETE"
    when "\u0003"
      exit 0
    when /^.$/
      if @current_string.length == 0 || @right_index == -1
        @current_string  << c
      else
        split_index = @right_index + 1
        @current_string = @current_string[0...split_index] + c + @current_string[split_index..-1]
      end
      clear_lines
      print header_string
      print @current_string
      clear_lines
      print header_string
      print @current_substring
    end
  end

  def clear_lines
      print "\b" * ((header_string + @current_string).length)
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
