require 'spec_helper'
require 'coopy'

describe Coopy do

  it "should exist" do
  	Coopy.should_not be_nil
  end

  it "should have a valid version" do
  	Coopy::VERSION.should =~ /[0-9]+.[0-9]+.[0-9]+/
  end

end