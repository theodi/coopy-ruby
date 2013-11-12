require 'spec_helper'

describe Coopy::CompareFlags do
  
  context "action settings" do

    it "should allow all by default" do
      flags = Coopy::CompareFlags.new
      flags.allow_update.should be_true
      flags.allow_insert.should be_true
      flags.allow_delete.should be_true
    end

    it "should allow update if set" do
      flags = Coopy::CompareFlags.new
      flags.acts = {"update" => true}
      flags.allow_update.should be_true
      flags.allow_insert.should be_false
      flags.allow_delete.should be_false
    end

    it "should allow insert if set" do
      flags = Coopy::CompareFlags.new
      flags.acts = {"insert" => true}
      flags.allow_update.should be_false
      flags.allow_insert.should be_true
      flags.allow_delete.should be_false
    end

    it "should allow delete if set" do
      flags = Coopy::CompareFlags.new
      flags.acts = {"delete" => true}
      flags.allow_update.should be_false
      flags.allow_insert.should be_false
      flags.allow_delete.should be_true
    end

  end

end