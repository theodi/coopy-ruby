module Coopy
  class SimpleCell

    attr_accessor :datum

    def initialize(datum = nil)
      @datum = datum
    end

    def to_s
      @datum.to_s
    end

  end
end
