module Coopy

  # Optimize access to arrays of primitives, avoid needing 
  # each item to be wrapped individually in some kind of access object.
  # Anticipate future optimization with view pools.
  
  module View

    def to_s(d) 
      raise NotImplementedError
    end

    def get_bag(d) 
      raise NotImplementedError
    end

    def get_table(d) 
      raise NotImplementedError
    end

    def has_structure?(d) 
      raise NotImplementedError
    end

    def equals(d1, d2) 
      raise NotImplementedError
    end

    def to_datum(str) 
      raise NotImplementedError
    end
    
  end
end
