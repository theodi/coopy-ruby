module Coopy
  class IndexItem

    attr_accessor :lst # Array<Int>

    def initialize
      @lst = []
    end

    def add(i)
      lst ||= []
      lst << i
      lst.length
    end

  end
end
