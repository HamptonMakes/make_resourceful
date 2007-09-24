require File.dirname(__FILE__) + '/spec_helper'

describe Resourceful::Serialize, ".normalize_attributes" do
  it "should return nil if given nil" do
    Resourceful::Serialize.normalize_attributes(nil).should be_nil
  end

  it "should return a basic hash if given a non-injectable attribute" do
    Resourceful::Serialize.normalize_attributes(:foo).should == {:foo => nil}
    Resourceful::Serialize.normalize_attributes(12).should == {12 => nil}
  end

  it "should return a basic hash with a symbol key if given a string attribute" do
    Resourceful::Serialize.normalize_attributes("foo").should == {:foo => nil}
  end

  it "should preserve hashes" do
    Resourceful::Serialize.normalize_attributes({:foo => nil, :bar => nil, :baz => nil}).should ==
      {:foo => nil, :bar => nil, :baz => nil}
    Resourceful::Serialize.normalize_attributes({:foo => 3, :bar => 1, :baz => 4}).should ==
      {:foo => 3, :bar => 1, :baz => 4}
    Resourceful::Serialize.normalize_attributes({:foo => 3, :bar => 1, :baz => [:foo, :bar]}).should ==
      {:foo => 3, :bar => 1, :baz => [:foo, :bar]}
  end

  it "should merge injectable attributes into one big hash" do
    Resourceful::Serialize.normalize_attributes([:foo, :bar, :baz]).should ==
      {:foo => nil, :bar => nil, :baz => nil}
    Resourceful::Serialize.normalize_attributes([:foo, :bar, {:baz => nil},
                                                 :boom, {:bop => nil, :blat => nil}]).should ==
      {:foo => nil, :bar => nil, :baz => nil, :boom => nil, :bop => nil, :blat => nil}
    Resourceful::Serialize.normalize_attributes([:foo, :bar, {:baz => 12},
                                                 :boom, {:bop => "foo", :blat => [:fee, :fi, :fo]}]).should ==
      {:foo => nil, :bar => nil, :baz => 12, :boom => nil, :bop => "foo", :blat => [:fee, :fi, :fo]}
  end
end

describe Array, " of non-serializable objects" do
  before :each do
    @array = [1, 2, 3, 4, "foo"]
  end

  it "should return itself for #to_serializable" do
    @array.to_serializable(nil).should == @array
  end

  it "should raise an error for #serialize" do
    lambda { @array.serialize(:yaml, :attributes => [:foo]) }.should raise_error("Not all elements respond to to_serializable")
  end
end
