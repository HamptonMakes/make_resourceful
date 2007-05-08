require 'active_record'

class User < ActiveRecord::Base
  attr_accessor :id, :options

  # A mock of the 'find' method in ActiveRecord
  def self.find(what, options = {})
    if what == :all
      [User.new, User.new]
    else
      user = User.new
      user.id = what.to_i
      user.options = options
      user
    end
  end
end
