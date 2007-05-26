class Thing < ActiveRecord::Base
  belongs_to :person
  has_many :properties
end
