require 'spec_helper'

describe Coopy::Unit do

  context "string conversion" do

    [
      [3,2,1],
      [1,2,3],
      [1,2,-2],
      [3,2,-1],
      [0,1,0],
    ].each do |lrp|

      it "should marshall strings in and out correctly (#{lrp.to_s})" do

        u = Coopy::Unit.new lrp[0], lrp[1], lrp[2]
        str = u.to_string

        nu = Coopy::Unit.new
        nu.from_string(str).should be_true

        u.l.should == nu.l
        u.r.should == nu.r
        u.p.should == nu.p

      end

    end
  end
end