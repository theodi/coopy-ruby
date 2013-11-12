module Coopy
  class CompareFlags

    # Should we treat the data as ordered?
    attr_accessor :ordered # boolean

    # Should we show unchanged rows in diffs?
    attr_accessor :show_unchanged # boolean

    # What is the minimum number of rows around a changed row we should show?
    attr_accessor :unchanged_context # integer

    # Should we always decorate the diff with numerical indexes showing order?
    attr_accessor :always_show_order # boolean

    # Should we never decorate the diff with numerical indexes?
    attr_accessor :never_show_order # boolean

    # Should we show unchanged columns in diffs?
    # (note that index/key columns needed to identify rows will be shown
    # even if we turn this flag off)
    attr_accessor :show_unchanged_columns # boolean

    # What is the minimum number of columns around a changed
    # column that we should show?
    attr_accessor :unchanged_column_context # integer

    # Should we always give a table header in diffs?
    attr_accessor :always_show_header # boolean

    # Optional filters for actions, set any of:
    #   "update", "insert", "delete"
    # to true to accept just those actions.
    attr_accessor :acts # Hash<String, Bool>

    def initialize()
      @ordered = true;
      @show_unchanged = false;
      @unchanged_context = 1;
      @always_show_order = false;
      @never_show_order = true;
      @show_unchanged_columns = false;
      @unchanged_column_context = 1;
      @always_show_header = true;
      @acts = nil;
    end

    def allow_update
      acts.nil? || acts.has_key?("update")
    end

    def allow_insert
      acts.nil? || acts.has_key?("insert")
    end

    def allow_delete
      acts.nil? || acts.has_key?("delete")
    end
    
  end
end

