module Coopy
  class TableComparisonState

    attr_accessor :p # Table
    attr_accessor :a # Table
    attr_accessor :b # Table

    attr_accessor :completed # boolean
    attr_accessor :run_to_completion # boolean

    # Are tables trivially equal?
    attr_accessor :is_equal # boolean
    attr_accessor :is_equal_known # boolean

    # Do tables have blatantly same set of columns?
    attr_accessor :has_same_columns # boolean
    attr_accessor :has_same_columns_known # boolean

    def initialize
      reset
    end

    def reset
      @completed = false
      @run_to_completion = true
      @is_equal_known = false
      @is_equal = false
      @has_same_columns = false
      @has_same_columns_known = false
    end

  end
end
