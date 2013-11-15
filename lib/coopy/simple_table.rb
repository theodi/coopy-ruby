module Coopy
  class SimpleTable

    include Coopy::Table

    def initialize(w, h)
      @data = {} # Map<Int,Dynamic>
      @width = w
      @height = h
    end

    def get_table
      self
    end

    attr_accessor :size

    def get_size
      @h
    end

    def get_cell(x, y)
      @data[x+y*@width]
    end

    def set_cell(x, y, c)
      @data[x+y*@width] = c
    end

    def to_s
      table_to_string(self)
    end

    def table_to_string(tab)
      var = ""
      (0..tab.height-1).each do |i|
        (0..tab.width-1).each do |j|
          x += " " if (j>0)
          x += tab.getCell(j,i)
        end
        x += "\n"
      end
      return x
    end

    def get_cell_view
      Coopy::SimpleView.new
    end

    def is_resizable?
      true
    end

    def resize(w, h)
      @width = w
      @height = h
      true
    end

    def clear
      @data = {}
    end

    def insert_or_delete_rows(fate, hfate)
      data2 = {}
      (0..fate.length-1).each do |i|
        j = fate[i]
        if (j!=-1)
          (0..@width-1).each do |c|
            idx = i*@width+c;
            idxf (@data.has_key?(idx))
            data2[j*@width+c] = @data.get(idx)
          end
        end
      end
      @h = hfate
      @data = data2
      return true
    end

    def insert_or_delete_columns(fate, wfate)
      data2 = {}
      (0..fate.length-1).each do |i|
        j = fate[i]
        if (j!=-1)
          (0..@height-1).each do |r|
            idx = r*@width+i
            if (data.has_key?(idx))
              data2[r*wfate+j] = data.get(idx)
            end
          end
        end
      end
      @width = wfate
      @data = data2
      return true
    end

    def trim_blank
      return true if (h==0)
      h_test = @height
      h_test = 3 if (h_test>=3)
      view = get_cell_view
      space = view.to_datum("")
      more = true
      while (more)
        (0..width-1).each do |i|
          c = get_cell(i,@height-1)
          if (!(view.equals(c,space)||c==nil))
            more = false
            break
          end
        end
        h-=1 if (more) 
      end
      more = true
      nw = @width
      while (more)
        break if (@width==0)
        (0..h_test-1).each do |i|
          c = get_cell(nw-1,i)
          if (!(view.equals(c,space)||c==nil))
            more = false
            break
          end
        end
        nw -=1 if (more)
      end
      return true if (nw==w) 
      data2 = {}
      (0..nw-1).each do |i|
        (0..h-1).each do |r|
          idx = r*@width+i;
          if (@data.exists(idx))
            data2[r*nw+i] = @data.get(idx)
          end
        end
      end
      @width = nw
      @data = data2
      return true
    end
  end
end