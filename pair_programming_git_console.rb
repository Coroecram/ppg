require_relative 'user'
require_relative 'ppgthread'
require_relative 'intro'
require_relative 'custom_errors'
require_relative 'ppgthread'
require_relative 'keypress'
require 'thwait'
require 'stringio'
require 'io/console'

class PairProgrammingGitConsole

  include Intro
  include KeyPress

  attr_accessor :thread, :switch_timer, :navigator, :driver

  def initialize()
    @navigator
    @driver
    git_init
    git_save_setup
    intro_prompt
    create_remotes
    @threads       = []
    @switch_timer  = 15
    @thread        = PPGThread.new(@switch_timer, @navigator, @driver, @threads, self)
    @thread.run
    ThreadsWait.all_waits(@threads)
  end

  def git_init
    `git init` if !(File.directory?('.git'))
  end

  def git_save_setup
    @sysname  = `git config --local user.name`[0...-1]
    @sysemail = `git config --local user.email`[0...-1]
  end

  def create_remotes
    remotes = `git remote`
    if remotes.include?('first_partner')
      `git remote remove first_partner`
    elsif remotes.include?('second_partner')
      `git remote remove second_partner`
    end
    `git remote add first_partner #{@navigator.repo}`
    `git remote add second_partner #{@driver.repo}`
  end
end

class String
    def is_i?
       !!(self =~ /\A[-+]?[0-9]+\z/)
    end
end
