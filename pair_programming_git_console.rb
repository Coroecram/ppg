require 'thwait'
require_relative 'ppgthread'
require 'io/console'

class PairProgrammingGitConsole

  attr_accessor :thread, :switch_timer, :navigator, :driver, :needs_nav_change

  def initialize()
    intro_prompt
    @threads = []
    @thread = PPGThread.new(@switch_timer, @user_2, @user_2, @threads, self)
    @thread.run
    ThreadsWait.all_waits(@threads)
    puts @threads
  end

  def intro_prompt(switch_timer=10, navigator={}, driver={})
    @switch_timer = switch_timer
    @navigator = navigator
    @driver = driver
  end
end

PairProgrammingGitConsole.new
