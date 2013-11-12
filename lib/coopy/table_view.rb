module Coopy
  class TableView
    include Coopy::View

    def to_s(d)
      d.to_s
    end
    
    def get_bag(d)
    	nil
    end

    def get_table(d)
      d
    end

    def has_structure?(d)
      true
    end

    def equals(d1, d2)
      puts("TableView#equals called")
      false
    end

    def to_datum(str)
      Coopy::SimpleCell.new(str)
    end

  end    
end