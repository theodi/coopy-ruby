module Coopy
  class CompareTable

    def attach(comp)
      @comp = comp # TableComparisonState
      more = compare_core
      while (more && @comp.run_to_completion) do
        more = compare_core
      end
      !more
    end

    def align 
      alignment = Coopy::Alignment.new
      align_core(alignment)
      alignment
    end

    def get_comparison_state 
      @comp
    end

    def align_core(align) 
      if (@comp.p.nil?) 
        align_core_2(align,@comp.a,@comp.b)
        return
      end
      align.reference = Coopy::Alignment.new
      align_core_2(align,@comp.p,@comp.b)
      align_core_2(align.reference,@comp.p,@comp.a)
      align.meta.reference = align.reference.meta
    end


    def align_core_2(align, a, b) 
      if (align.meta.nil?) 
        align.meta = Coopy::Alignment.new
      end
      align_columns(align.meta,a,b)
      column_order = align.meta.to_order
      common_units = []
      column_order.get_list.each do |unit| 
        if (unit.l>=0 && unit.r>=0 && unit.p!=-1) 
          common_units << unit
        end
      end

      align.range(a.height,b.height)
      align.tables(a,b)
      align.set_rowlike(true)
        
      w  = a.width
      ha = a.height
      hb = b.height

      av = a.get_cell_view

      # If we have more columns than we have time to process their
      # combinations, we need to haul out some heuristics.

      n = 5
      columns = []
      if (common_units.length>n) 
        columns_eval = []
        (0..common_units.length-1).each do |i| 
          ct = 0
          mem = {}
          mem2 = {}
          ca = common_units[i].l
          cb = common_units[i].r
          (0..ha-1).each do |j| 
            key = av.to_s(a.get_cell(ca,j))
            if (!mem.has_key?(key)) 
              mem[key] = 1
              ct+=1
            end
          end
          (0..hb-1).each do |j| 
            key = av.to_s(b.get_cell(cb,j))
            if (!mem2.has_key?(key)) 
              mem2[key] = 1
              ct+=1
            end
          end
          columns_eval << [i,ct]
        end
        columns_eval.sort { |a,b| a[1] <=> b[1] }
        columns = columns_eval.map{ |v| v[0] }
        columns = columns.slice(0,n)
      else
        (0..common_units.length-1).each do |i| 
          columns << i
        end
      end

      top = (2 ** columns.length).round

      pending = {}
      (0...ha).each do |j| 
        pending[j] = j
      end
      pending_ct = ha
      
      (0...top).each do |k| 
        next if (k==0)
        break if (pending_ct == 0)
        active_columns = []
        kk = k
        at = 0
        while (kk>0) 
          if (kk%2==1) 
            active_columns << columns[at]
          end
          kk >>= 1
          at+=1
        end

        index = IndexPair.new
        (0...active_columns.length).each do |k|
          unit = common_units[active_columns[k]]
          index.add_columns(unit.l,unit.r)
          align.add_index_columns(unit)
        end
        index.index_tables(a,b)

        h = a.height
        h = b.height if (b.height>h)
        h = 1 if (h<1)
        wide_top_freq = index.get_top_freq
        ratio = wide_top_freq
        ratio /= (h+20) # "20" allows for low-data 
        next if (ratio>=0.1) # lousy no-good index, move on

        if @indexes
          @indexes << index
        end

        fixed  = []
        pending.keys.each do |j| 
          cross = index.query_local(j)
          spot_a = cross.spot_a
          spot_b = cross.spot_b
          next if (spot_a!=1 || spot_b!=1)
          fixed << j
          align.link(j,cross.item_b.lst[0])
        end
        (0...fixed.length).each do |j|
          pending.delete(fixed[j])
          pending_ct-=1
        end
      end
      # we expect headers on row 0 - link them even if quite different.
      align.link(0,0)
    end

    def align_columns(align, a, b) 
      align.range(a.width,b.width)
      align.tables(a,b)
      align.set_rowlike(false)
        
      slop = 5
      
      va = a.get_cell_view
      vb = b.get_cell_view
      ra_best = 0
      rb_best = 0
      ct_best = -1
      ma_best = nil
      mb_best = nil
      ra_header = 0
      rb_header = 0
      ra_uniques = 0
      rb_uniques = 0
      (0..slop-1).each do |ra| 
        break if (ra>=a.height)
        (0..slop-1).each do |rb| 
          break if (rb>=b.height)
          ma = {}
          mb = {}
          ct = 0
          uniques = 0
          (0..a.width-1).each do |ca| 
            key = va.to_s(a.get_cell(ca,ra))
            if (ma.has_key?(key)) 
              ma[key] = -1
              uniques-=1
            else 
              ma[key] = ca
              uniques+=1
            end
          end
          if (uniques>ra_uniques) 
            ra_header = ra
            ra_uniques = uniques
          end
          uniques = 0
          (0..b.width-1).each do |cb|
            key = vb.to_s(b.get_cell(cb,rb))
            if (mb.has_key?(key)) 
              mb[key] = -1
              uniques-=1
            else 
              mb[key] = cb
              uniques+=1
            end
          end
          if (uniques>rb_uniques) 
            rb_header = rb
            rb_uniques = uniques
          end

          ma.keys.each do |key| 
            i0 = ma[key]
            i1 = mb[key]
            if (i1 && i1>=0 && i0>=0) 
              ct+=1
            end
          end

          if (ct>ct_best) 
            ct_best = ct
            ma_best = ma
            mb_best = mb
            ra_best = ra
            rb_best = rb
          end
        end
      end

      return if (ma_best.nil?)
      ma_best.keys.each do |key|
        i0 = ma_best[key]
        i1 = mb_best[key]
        if (!i1.nil? && !i0.nil?)
          align.link(i0,i1)
        end
      end
      align.headers(ra_header,rb_header)
    end

    def test_has_same_columns 
      p = @comp.p
      a = @comp.a
      b = @comp.b
      eq = has_same_columns_2(a,b)
      if (eq && p)
        eq = has_same_columns_2(p,a)
      end
      @comp.has_same_columns = eq
      @comp.has_same_columns_known = true
      return true
    end

    def has_same_columns_2(a, b)
      if (a.width!=b.width) 
        return false
      end
      if (a.height==0 || b.height==0) 
        return true
      end

      # check for a blatant header - should only do this
      # for meta-data free tables, that may have embedded headers
      av = a.get_cell_view
      (0..a.width-1).each do |i|
        ((i+1)..a.width-1).each do |j|
          if (av.equals(a.get_cell(i,0),a.get_cell(j,0))) 
            return false
          end
        end
        if (!av.equals(a.get_cell(i,0),b.get_cell(i,0))) 
          return false
        end
      end

      return true
    end

    def test_is_equal
      p = @comp.p
      a = @comp.a
      b = @comp.b
      eq = is_equal_2(a,b)
      if (eq && p) 
        eq = is_equal_2(p,a)
      end
      @comp.is_equal = eq
      @comp.is_equal_known = true
      true
    end
    
    def is_equal_2(a, b) 
      if (a.width!=b.width || a.height!=b.height) 
        return false
      end
      av = a.get_cell_view
      (0..a.height-1).each do |i|
        (0..a.width-1).each do |j| 
          if (!av.equals(a.get_cell(j,i),b.get_cell(j,i))) 
            return false
          end
        end
      end
      return true
    end

    def compare_core
      return false if (@comp.completed) 
      if (!@comp.is_equal_known) 
        return test_is_equal
      end
      if (!@comp.has_same_columns_known) 
        return test_has_same_columns
      end
      @comp.completed = true
      false
    end

    def store_indexes
      @indexes = []
    end

    def get_indexes
      @indexes
    end
  end
end