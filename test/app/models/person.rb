class Person < ActiveRecord::Base
  validates_presence_of :name

  has_many :things
end
