module Coopy

  class Unit

    attr_accessor :l # integer
    attr_accessor :r # integer
    attr_accessor :p # integer

    def initialize(l = -2, r = -2, p = -2)
        @l = l;
        @r = r;
        @p = p;
    end

    def lp
      (@p==-2) ? @l : @p
    end

    def describe(i)
      (i>=0) ? ("" + i.to_s) : "-"
    end

    def to_s
      return describe(@p) + "|" + describe(@l) + ":" + describe(@r) if (@p>=-1)
      describe(@l) + ":" + describe(@r)
    end

    def from_string(txt)
      txt += "]"
      at = 0
      txt.each_char do |ch|
        case ch
        when /[0-9]/
          at *= 10;
          at += ch.to_i
        when '-'
          at = -1
        when '|'
          @p = at
          at = 0
        when ':'
          @l = at
          at = 0
        when ']'
          @r = at
          return true
        end
      end
      false
    end

  end
end
