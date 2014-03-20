require 'spec_helper'

describe Coopy::CompareTable do
  context "diff" do

    it "should allow comparison of tables with different numbers of columns" do
      old_table = Coopy::CsvTable.new(CSV('C0\n0').read)
      new_table = Coopy::CsvTable.new(CSV('C0,C1\n0,1').read)
      alignment = Coopy.compare_tables(old_table,new_table).align
      flags = Coopy::CompareFlags.new
      flags.show_unchanged = true
      flags.show_unchanged_columns = true


      highlighter = Coopy::TableDiff.new(alignment,flags)

      diff_table = Coopy::SimpleTable.new(0,0)
      highlighter.hilite diff_table
      diff_table.to_s.should be == "! +++ +++ +++ ---\n@@ C0 C1\\n0 1 C0\\n0\n"
    end

  end
end