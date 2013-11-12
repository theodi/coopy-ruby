module Coopy

  module Bag

    attr_reader :size # integer
    
    def get_item(x)
      raise NotImplementedError
    end

    def get_item_view
      raise NotImplementedError
    end

  end
end

