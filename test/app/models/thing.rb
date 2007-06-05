class Thing < ActiveRecord::Base
  belongs_to :person
  belongs_to :user
  has_many :properties

  validates_length_of :name, :maximum => 30
end
