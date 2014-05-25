require_relative 'collection'

class UserCollection < Collection
  validates_uniqueness_of :email

  def create_user(options)
    collection << User.new(options)
  end
end


class User
  attr_accessor :email

  def initialize(options)
    @email = options[:email]
  end
end
