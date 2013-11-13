module Coopy

  def self.compare_tables(local, remote)
    ct = Coopy::CompareTable.new
    comp = Coopy::TableComparisonState.new
    comp.a = local
    comp.b = remote
    ct.attach comp
    ct
  end

end