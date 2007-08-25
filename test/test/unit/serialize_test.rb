require File.dirname(__FILE__) + '/../test_helper'
require 'resourceful/serialize'

class SerializeTest < Test::Unit::TestCase
  fixtures :parties, :people, :parties_people
  
  def test_should_generate_hash_for_model
    assert_equal(hash_for_fun_party,
                 parties(:fun_party).to_hash([:name, {:people => [:name]}]))
  end
  
  def test_to_s_should_return_format
    assert_equal({'party' => hash_for_fun_party},
                 YAML.load(parties(:fun_party).serialize(:yaml, :attributes => [:name, {:people => [:name]}])))
  end
end
