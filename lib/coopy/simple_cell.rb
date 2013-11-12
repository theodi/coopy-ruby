module Coopy
  class SimpleCell

    attr_accessor :datum

    def initialize(datum = nil)
      @datum = datum
    end

    def to_string
      @datum.to_string
    end

  end
end
