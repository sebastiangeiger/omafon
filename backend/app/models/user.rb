class UserCollection
  def initialize
    @collection = []
  end
  def create_user(options)
    @collection << User.new(options)
  end
  def size
    @collection.size
  end
end
class User
  def initialize(options)
  end
end
