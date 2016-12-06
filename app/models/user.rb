require 'digest/sha1'
class User < CouchRest::Model::Base
  use_database "users"

  cattr_accessor :current

  property :username, String
  property :first_name, String
  property :last_name, String
  property :password, String
  property :salt, String
  property :user_role, String
  property :voided, TrueClass, :default => false

  timestamps!

  design do
    view :by_username
  end

  before_save :encrypt_password

  def role
      self.user_role
  end

  def self.random_string(len)
    #generat a random password consisting of strings and digits
    chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
    newpass = ""
    1.upto(len) { |i| newpass << chars[rand(chars.size-1)] }
    return newpass
  end

  def encrypt_password
    self.salt = User.random_string(10)
    self.password = encrypt(self.password, self.salt)
  end

  def encrypt(password,salt)
    Digest::SHA1.hexdigest(password+salt)
  end

  def self.authenticate(username, password)

    user = User.by_username.key(username).first rescue nil

    if !user.nil?
      salt = Digest::SHA1.hexdigest(password + user.salt)

      if salt == user.password

        return true

      else
        return false
      end

    else

      return false

    end
  end

  def self.create_user(username, password, user_role)
    exists = User.by_username.key(username).first

    if !exists.blank?
      return ["Username is already taken", nil]
    else
      new_user = User.new()
      new_user.password = password
      new_user.username = username
      new_user.user_role = user_role
      new_user.save
    end
  end

  def User.update_user(user_name_old, username, password, user_role)
    user = User.by_username.key(user_name_old).first
    user.username = username
    user.password = password
    user.user_role = user_role
    if user.save
      return ["Details for user #{username} successfully updated", true]
    else
      return ["Could not update details for user #{username}", nil]
    end
  end
end
