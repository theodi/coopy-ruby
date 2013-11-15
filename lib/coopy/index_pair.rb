module Coopy
  class IndexPair

    def initialize
      @ia = Index.new
      @ib = Index.new
      @quality = 0
    end

    def add_column(i)
      @ia.add_column i
      @ib.add_column i
    end

    def add_columns(ca, cb)
      @ia.add_column ca
      @ib.add_column cb
    end

    def index_tables(a, b)
      @ia.index_table a
      @ib.index_table b
      # calculate
      #   P(present and unique within a AND present and unique with b)
      #     for rows in a
      good = 0
      @ia.items.keys.each do |key|
        item_a = @ia.items[key]
        spot_a = item_a.lst.length
        item_b = @ib.items[key]
        spot_b = 0;
        spot_b = item_b.lst.length if item_b
        if spot_a == 1 && spot_b == 1
          good += 1
        end
      end
      @quality = good / [1.0,a.height].max
    end

    def query_by_key(ka)
      result = CrossMatch.new
      result.item_a = @ia.items[ka]
      result.item_b = @ib.items[ka]
      result.spot_a = result.spot_b = 0
      if ka != ""
        result.spot_a = result.item_a.lst.length if result.item_a
        result.spot_b = result.item_b.lst.length if result.item_b
      end
      result
    end

    def query_by_content(row)
      ka = @ia.to_key_by_content(row)
      query_by_key ka
    end

    def query_local(row)
      ka = @ia.to_key(@ia.get_table,row)
      query_by_key ka
    end

    def get_top_freq
        [@ib.top_freq, @ia.top_freq].max
    end

    def get_quality
      @quality
    end

  end
end

