require File.dirname(__FILE__) + '/spec_helper'

describe Resourceful::Base, ".made_resourceful" do
  before(:each) { Resourceful::Base.made_resourceful.replace [] }

  it "should store blocks when called with blocks and return them when called without a block" do
    5.times { Resourceful::Base.made_resourceful(&should_be_called) }
    Resourceful::Base.made_resourceful.each(&:call)
  end
end
