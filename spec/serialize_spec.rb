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

describe Array, " of serializable objects" do
  before :each do
    @cat = stub_model("Cat")
    @dog = stub_model("Dog")
    @array = %w{brown yellow green}.zip(%w{rex rover fido}).
      map { |c, d| @cat.new(:fur => c, :friend => @dog.new(:name => d)) }
  end

  it "should return an array of serializable hashes for #to_serializable" do
    @array.to_serializable([:fur]).should == [{'fur' => 'brown'}, {'fur' => 'yellow'}, {'fur' => 'green'}]
  end

  it "should follow deep attributes for #to_serializable" do
    @array.to_serializable([:fur, {:friend => :name}]).should ==
      [{'fur' => 'brown',  'friend' => {'name' => 'rex'}},
       {'fur' => 'yellow', 'friend' => {'name' => 'rover'}},
       {'fur' => 'green',  'friend' => {'name' => 'fido'}}]
  end

  it "should raise an error if #serialize is called without the :attributes option" do
    lambda { @array.serialize(:yaml, {}) }.should raise_error("Must specify :attributes option")
  end

  it "should serialize to a hash with a pluralized root for #serialize" do
    YAML.load(@array.serialize(:yaml, :attributes => [:fur, {:friend => :name}])).should ==
      {"cats" => [{'fur' => 'brown',  'friend' => {'name' => 'rex'}},
                  {'fur' => 'yellow', 'friend' => {'name' => 'rover'}},
                  {'fur' => 'green',  'friend' => {'name' => 'fido'}}]}
  end

  it "should serialize to an XML document with a pluralized root for #serialize(:xml, ...)" do
    doc = REXML::Document.new(@array.serialize(:xml, :attributes => [:fur, {:friend => :name}]),
                              :ignore_whitespace_nodes => :all)
    doc.root.name.should == "cats"
    cats = doc.get_elements('/cats/cat')
    cats.size.should == 3
    cats.zip(%w{brown yellow green}, %w{rex rover fido}) do |cat, fur, dog|
      cat.children.find { |e| e.name == "fur" }.text.should == fur
      cat.children.find { |e| e.name == "friend" }.children[0].text.should == dog
    end
  end
end
