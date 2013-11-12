module Coopy
  class CellInfo

    attr_accessor :value
    attr_accessor :pretty_value
    attr_accessor :category
    attr_accessor :category_given_tr
    
    # relevant to updates, conflicts
    attr_accessor :separator
    attr_accessor :updated
    attr_accessor :conflicted
    attr_accessor :pvalue
    attr_accessor :lvalue
    attr_accessor :rvalue

    def to_s
      return value if (!updated)
      return lvalue + "::" + rvalue if (!conflicted)
      return pvalue + "||" + lvalue + "::" + rvalue;
    end

  end
end
