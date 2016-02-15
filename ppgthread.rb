require_relative 'keypress'
require_relative 'custom_errors'
require_relative 'user'
require 'io/console'
require 'byebug'
require 'date'

class PPGThread
  include KeyPress

    def initialize(switch_time, navigator, driver, threads, pairing_manager)
        @switch_time     = switch_time
        @navigator       = driver
        @driver          = navigator
        @pairing_manager = pairing_manager
        switch_roles #switch_roles to run git config
        @threads       = threads
        @strings       = [""]
        @strings_index = -1
        @current_string = @strings[@strings_index]
        set_time
        @responding  = false
        @last_commit = Time.now
        @last_commit_alert = Time.now
        @right_index = -1
        @last_keypress = Time.now
    end

    def set_time(delta=nil)
        delta = delta || @switch_time
        @next_switch_time = Time.now + (delta * 60)
    end

    def run
        puts "\n\n\nEnjoy Pair Programming Git\n"
        puts "EXTRA COMMANDS:\n"
        puts "ppg switch"
        puts "    switches the navigator, and user of record"
        puts "ppg modify -attribute -role new-value"
        puts "     change email, name or repo attribute of a user"
        puts "     ppg modify -email -driver for@example.com"
        puts "ppg set-time"
        puts "     change switch timer"
        puts "ppg pause"
        puts "    pauses the timer"
        puts "ppg unpause"
        puts "    unpauses the timer\n"
        print header_string
        set_time
        @threads << Thread.new do
            loop do
                if @responding
                    next
                end
                string = handle_key_press
                if string
                    @responding = true
                    process(string)
                    @responding = false
                    if @next_switch_time < Time.now
                        if @current_string.length < 1
                            clear_lines
                            print " " * (`tput cols`.to_i)
                            clear_lines
                            puts ""
                            puts "It has been #{@switch_time} minutes.  Please change the navigator with ppg switch".upcase
                            print header_string
                        else
                            puts ""
                            puts "\nIt has been #{@switch_time} minutes.  Please change the navigator with ppg switch".upcase
                            print header_string
                            print @current_string
                            clear_lines
                            print header_string
                            print @current_string[0..@right_index]
                        end
                    end
                end
            end
        end
        @threads << Thread.new do
            loop do
                if @responding
                    next
                end
                if Time.now - @last_keypress > 5
                    clear_lines
                    print header_string
                    print @current_string
                    clear_lines
                    print header_string
                    print @current_string[0..@right_index]
                end
                if (@next_switch_time - Time.now).floor == 0
                    clear_lines
                    print "\nIt has been #{@switch_time} minutes.  Please change the navigator with ppg switch\n".upcase
                    clear_lines
                    print header_string
                    print @current_string
                    clear_lines
                    print header_string
                    print @current_string[0..@right_index]
                end
                if Time.now - @last_commit_alert > 300
                    @last_commit_alert = Time.now
                    last_commit - Time.now - @last_commit
                    clear_lines
                    print "\n\r"
                    print "\nIt has been #{last_commit/60} minutes consider committing\n".upcase
                    print "\r"
                    print header_string
                    print @current_string
                    clear_lines
                    print header_string
                    print @current_string[0..@right_index]
                    sleep 10
                end
                sleep 1
            end
        end
        @threads.each {|thread| thread.abort_on_exception = true}
    end

    def process(input)
        output = ""
        if input.strip.start_with?('ppg')
            if input == 'ppg set-time'
              reset_time
            elsif input == 'ppg switch'
              switch_roles
            elsif input.start_with?('ppg modify')
              modify_user(input)
            elsif input == 'ppg pause'
              pause
            elsif input == 'ppg unpause'
              ppgunpause
            else
                string = "#{input.gsub('ppg', 'git')}"
                puts(string)
                process(string)
            end
        else
            if input.start_with?('git commit')
                output = commit(input)
            elsif input.start_with?('git push')
                output = push
            else
                output = `#{input}`
            end
        end
        if output.length > 0
            puts output
        end
        print "\r"
        print header_string
        rescue => boom
            puts boom
            print header_string
    end

    def pause
        if !@paused
            @paused = (@next_switch_time - Time.now)
        end
    end

    def unpause
        if @paused
            set_time(@paused/60)
            @paused = nil
        end
    end

    def push
        output = ""
        output << `git push first_partner`
        output << "\n"
        output << `git push second_partner`
        return output
    end

    def switch_roles
      @navigator, @driver = @driver, @navigator
      if @paused
        @paused = @switch_time * 60
      else
        set_time
      end
      debugger
      `git config --local --replace-all user.name #{@navigator.name}`
      `git config --local --replace-all user.email #{@navigator.email}`
    end

    def reset_time
        puts "How long would you like this round to be?"
        num = gets.to_i

        if @paused
            @paused = num * 60
        else
            set_time(num)
         end
    end

    def modify_user(input)
      parsed_input = input.split(" ").drop(2)
      raise FormatError, "Please enter a valid command 'ppg modify -attribute -role new-value'" if parsed_input.length < 3
      attr = parsed_input.shift
      raise FormatError, "Please enter a valid attribute (-name/-email/-repo)" if !(attr =~ /\A-(name|email|repo)\z/)
      role = parsed_input.shift
      raise FormatError, "Please enter a valid role (-navigator/-driver)" if !(role =~ /\A-(navigator|driver)\z/)
      value = parsed_input.join(" ")
      raise NoInputError, "Please enter a new value" if !value

      if attr == '-email'
        raise FormatError, "Please enter a valid email address" if !(User.valid_email?(value))
      elsif attr == '-repo'
        raise FormatError, "Please enter a valid Github Repository address" if !(User.valid_repo?(value))
      end

      user = (role == '-navigator' ? @navigator : @driver)
      user.instance_variable_set("@#{attr[1..-1]}".to_sym, value)
    rescue StandardError => e
      puts e.message
    end

    def commit(string)
        unless string.include?('-m')
            puts "Please enter a commit message:"
            message = gets.chomp
            unless message.include?('"')
                message = "\"#{message}\""
            end
            string += " -m #{message}"
        end
        puts string
        output = `#{string}`
        @last_commit = Time.now
        @last_commit_alert = Time.now
        return output
    end

end
