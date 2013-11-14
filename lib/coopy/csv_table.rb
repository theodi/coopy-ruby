require 'csv'

module Coopy
  class CsvTable

    include Coopy::Table

    def initialize(csv)
      @csv = csv
      @height = csv.lineno
      @width = csv.headers.length rescue 0
    end

    def get_cell(x, y) 
      @csv[y][x]
    end

    def set_cell(x, y, cell) 
      @csv[y][x] = cell
    end

    def get_cell_view
      Coopy::CsvView.new
    end

    def is_resizable? 
      false
    end

    def resize(w, h) 
      raise NotImplementedError
    end

    def clear 
      @csv = CSV::Table.new
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