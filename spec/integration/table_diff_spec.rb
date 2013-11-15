require 'spec_helper'

describe "diffing tables" do

  [
    "planetary_bodies",
  ].each do |name|

    it "should generate correct HTML for #{name}" do

      old_table = Coopy::CsvTable.new(CSV.parse(load_fixture("#{name}_old.csv")))
      new_table = Coopy::CsvTable.new(CSV.parse(load_fixture("#{name}_new.csv")))
 
      alignment = Coopy.compare_tables(old_table,new_table).align

      table_diff = Coopy::SimpleTable.new(0,0)

      flags = Coopy::CompareFlags.new
      highlighter = Coopy::TableDiff.new(alignment,flags)
      highlighter.hilite table_diff

      expected_diff = CSV.parse(load_fixture("#{name}_diff.csv"))
      expected_diff.each_with_index do |row, row_index|
        row.each_with_index do |cell, col_index|
          expected = table_diff.get_cell(col_index, row_index).to_s
          got = cell.to_s
          got = '' if got == "NULL"
          expected.should eql(got), "row:#{row_index} col:#{col_index} was '#{got}' instead of '#{expected}'"
        end
      end

    end

    it "should generate correct HTML for #{name}" do

      old_table = Coopy::CsvTable.new(CSV.parse(load_fixture("#{name}_old.csv")))
      new_table = Coopy::CsvTable.new(CSV.parse(load_fixture("#{name}_new.csv")))
 
      alignment = Coopy.compare_tables(old_table,new_table).align

      table_diff = Coopy::SimpleTable.new(0,0)

      flags = Coopy::CompareFlags.new
      highlighter = Coopy::TableDiff.new(alignment,flags)
      highlighter.hilite table_diff

      diff2html = Coopy::DiffRender.new
      diff2html.render table_diff
      diff_html = diff2html.html

      diff_html.should == load_fixture("#{name}.html")

    end

  end
end