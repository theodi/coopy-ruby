module Coopy
  module Table

    attr_reader :height # integer
    attr_reader :width # integer

    def get_cell(x, y) 
      raise NotImplementedError
    end

    def set_cell(x, y, cell) 
      raise NotImplementedError
    end

    def get_cell_view
      raise NotImplementedError
    end

    def is_resizable? 
      raise NotImplementedError
    end

    def resize(w, h) 
      raise NotImplementedError
    end

    def clear 
      raise NotImplementedError
    end

    def insert_or_delete_rows(fate, hfate) 
      raise NotImplementedError
    end

    def insert_or_delete_columns(fate, wfate) 
      raise NotImplementedError
    end

    def trim_blank 
      raise NotImplementedError
    end
    
  end
end
