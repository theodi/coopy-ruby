module Coopy
  class IndexItem

    attr_accessor :lst # Array<Int>

    def add(i)
      lst ||= []
      lst << i
      lst.length
    end

  end
end
