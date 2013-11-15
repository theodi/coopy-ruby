module Coopy
  class Index

    attr_accessor :items # Hash<String,IndexItem>
    attr_accessor :keys # Array<String>
    attr_accessor :top_freq # integer
    attr_accessor :height # integer

    def initialize
      @items = {}
      @cols = [] # Array<integer>
      @keys = []
      @top_freq = 0
      @height = 0
      @v = nil # View
      @indexed_table = nil # Table
    end
 
    def add_column(i)
      @cols << i
    end

    def index_table(t)
      @indexed_table = t
      (0...t.height).each do |i|
        key = ""
        if @keys.length > i
          key = @keys[i]
        else
          key = to_key(t,i)
          @keys << key
        end
        item = @items[key]
        if item.nil?
          item = IndexItem.new
          @items[key] = item
        end
        ct = item.add(i)
        @top_freq = ct if ct>@top_freq
      end
      @height = t.height
    end

    def to_key(table, i)
      wide = ""
      @v = table.get_cell_view if @v.nil?
      @cols.each_with_index do |col, k|
        d = table.get_cell(col,i)
        txt = @v.to_s(d)
        next if (txt=="" || txt=="null" || txt=="undefined")
        wide += " // " if (k>0)
        wide += txt
      end
      wide
    end

    def to_key_by_content(row)
      wide = ""
      @cols.each_with_index do |col, k|
        txt = row.get_row_string(col)
        next if (txt=="" || txt=="null" || txt=="undefined")
        wide += " // " if (k>0)
        wide += txt
      end
      wide
    end

    def get_table
      @indexed_table
    end

  end
end