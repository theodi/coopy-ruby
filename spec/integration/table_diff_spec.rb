require 'spec_helper'

describe "diffing tables" do

  [
    "planetary_bodies",
  ].each do |name|

    it "should generate correct HTML for #{name}" do

      old_table = Coopy::CsvTable.new(CSV.new(load_fixture("#{name}_old.csv")))
      new_table = Coopy::CsvTable.new(CSV.new(load_fixture("#{name}_new.csv")))
 
      alignment = Coopy.compare_tables(old_table,new_table).align
 
      table_diff = Coopy::CsvTable.new(CSV.new(load_fixture("#{name}_new.csv")))

      flags = Coopy::CompareFlags.new
      # highlighter = Coopy::TableDiff.new(alignment,flags)
      # highlighter.hilite table_diff

      # diff2html = Coopy::DiffRender.new
      # diff2html.render table_diff
      # diff_html = diff2html.html

      # diff_html.should == load_fixture("#{name}.html")

    end

  end
end