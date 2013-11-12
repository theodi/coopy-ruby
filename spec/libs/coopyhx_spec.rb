require 'spec_helper'
require 'coopyhx'

describe Coopyhx do

  it "should exist" do
  	Coopyhx.should_not be_nil
  end

  it "should have a valid version" do
  	Coopyhx::VERSION.should =~ /[0-9]+.[0-9]+.[0-9]+/
  end

end