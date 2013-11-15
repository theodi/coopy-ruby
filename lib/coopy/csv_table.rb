require 'csv'

module Coopy
  class CsvTable

    include Coopy::Table

    def initialize(csv)
      @csv = csv
      @height = csv.size
      @width = csv[0].size
    end

    def get_cell(x, y) 
      @csv[y][x]
    end

    def set_cell(x, y, cell) 
      @csv[y][x] = cell
    end

    def get_cell_view
      Coopy::SimpleView.new
    end

    def is_resizable? 
      false
    end

    def resize(w, h) 
      raise NotImplementedError
    end

    def clear 
      @csv = []
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
