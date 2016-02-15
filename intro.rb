module Intro

  def intro_prompt
    @strings           = [""]
    @strings_index     = -1
    @right_index       = -1
    @current_string    = @strings[@strings_index]
    @current_substring = @current_string[0..@right_index]
    @navigator         = new_user("navigator")
    @driver            = new_user("driver")
    @switch_timer      = switch_timer_prompt
  end

  def new_user(role, identifier)
    name  = name_prompt(role)
    email = email_prompt(role)
    repo  = repo_prompt(role)
    info  = {name: name, email: email, repo: repo, role: role}

    confirm_user_info?(info) ? User.new(info) : new_user(role)
  end

  def name_prompt(role)
    puts "\nWhat is the #{role}'s name?"
    name = input_prompt
    raise InputError, "Please enter a name" if name == ""

    name
    rescue ArgumentError => e
      puts e.message
      retry
  end

  def email_prompt(role)
    puts "\nWhat is the #{role}'s email?"
    email = input_prompt
    raise DuplicateError, "Driver and Navigator cannot have the same email!" if @navigator && @navigator.email == email
    raise FormatError, "Please enter a valid email address" if !(User.valid_email?(email))

    email
    rescue ArgumentError => e
      puts e.message
      retry
  end

  def repo_prompt(role)
    puts "\nWhat is the #{role}'s git repository url?"
    repo = input_prompt
    raise DuplicateError, "Driver and Navigator cannot have the same repo!" if @navigator && @navigator.repo == repo
    raise FormatError, "Please enter a valid Github Repository address" if !(User.valid_repo?(repo))

    repo
    rescue ArgumentError => e
      puts e.message
      retry
  end

  def confirm_user_info?(info)
    puts "\nRole:  #{info[:role]}"
    puts "Name:  #{info[:name]}"
    puts "Email:  #{info[:email]}"
    puts "Repo:  #{info[:repo]}"
    puts "Is this correct? (y/n)"

    confirm_prompt
    rescue InputError => e
      puts e.message
      retry
  end

  def switch_timer_prompt
    puts 'Switch every 15 minutes? (press enter or enter different number)'
    switch_timer = input_prompt
    if switch_timer =~ /([yn]+[eo]?s?|^$)/
      if timer_confirm?()
        15
      else
        raise InputError
      end
    elsif switch_timer.is_i?
      switch_timer = switch_timer.to_i
      if switch_timer <= 120 && switch_timer >= 15
        if timer_confirm?(switch_timer)
          switch_timer
        else
           raise InputError
         end
      else
        raise OutofBoundsError, "Value must be between 15 and 120"
      end
    else
      raise NotIntegerError, "Enter a number between 15 and 120"
    end

    rescue InputError
      puts
      retry
    rescue OutofBoundsError => e
      puts "#{e.message}\n"
      retry
    rescue NotIntegerError => e
      puts "#{e.message}\n"
      retry
  end

  def timer_confirm?(timer = 15)
    puts "Switch every #{timer} minutes? (y/n)"
    confirm_prompt

    rescue InputError => e
      puts "#{e.message}\n"
      retry
  end

  def confirm_prompt
    confirmation = input_prompt
    if !(confirmation.downcase =~ /([yn]+[eo]?s?|^$)/)
      raise InputError, "Enter y or n"
    else
      return confirmation.downcase =~ /(y+e?s?|^$)/
    end
  end

end
