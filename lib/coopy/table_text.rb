module Coopy
  class TableText

    def initialize(rows)
      @rows = rows
      @view = rows.get_cell_view
    end

    def get_cell_text(x, y)
      @view.to_s(@rows.get_cell(x,y))
    end

  end
end
