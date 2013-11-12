require 'spec_helper'

describe Coopy::Ordering do
  
  it "should convert order to string correctly" do
    # test default behaviour
    o = Coopy::Ordering.new
    o.to_s.should == ''
    # add a couple of units
    o.add 1,2,3
    o.add 3,2,1
    o.to_s.should == "3|1:2, 1|3:2"
  end

  it "should not ignore parent if not set" do
    o = Coopy::Ordering.new
    o.add 1,2,3
    o.to_s.should == "3|1:2"
  end

  it "should ignore parent if set" do
    o = Coopy::Ordering.new
    o.ignore_parent
    o.add 1,2,3
    o.to_s.should == "1:2"
  end

end