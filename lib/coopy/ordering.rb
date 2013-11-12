module Coopy
  class Ordering

    def initialize
      @order = []
      @ignore_parent = false
    end

    def add(l, r, p = -2)
      p = -2 if @ignore_parent
      @order << Coopy::Unit.new(l,r,p)
    end

    def get_list
      @order
    end

    def to_s
      @order.map{|x| x.to_s}.join(", ")
    end

    def ignore_parent
      @ignore_parent = true;
    end

  end
end