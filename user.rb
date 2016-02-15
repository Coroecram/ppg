class User

attr_accessor :name, :email, :repo, :role

  def initialize(options)
    @name = options[:name]
    @email = options[:email]
    @repo = options[:repo]
    @role = options[:role]
  end

  def switch_role
    role = (role == 'navigator' ? 'driver' : 'navigator')
  end

  def self.valid_repo?(repo)
    !!(repo =~ /https:\/\/github.com\/\S+\/\S+\.git/)
  end

  def self.valid_email?(email)
    !!(email =~ /\A[^@\s]+@([^@\s]+\.)+[^@\s]+\z/)
  end

end
