class Thing < ActiveRecord::Base
  belongs_to :person
  belongs_to :user
  has_many :properties

end
