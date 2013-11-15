module Coopy
  class TableDiff 

    def initialize(align, flags) 
      @align = align # Alignment
      @flags = flags # CompareFlags
    end

    def get_separator(t, t2, root)
      sep = root
      w = t.width
      h = t.height
      view = t.get_cell_view
      (0..h-1).each do |y|
        (0..w-1).each do |x|
          txt = view.to_s(t.get_cell(x,y))
          next if (txt.nil?)
          while (txt.indexOf(sep)>=0) 
            sep = "-" + sep
          end
        end
      end
      if (t2) 
        w = t2.width
        h = t2.height
        (0..h-1).each do |y|
          (0..w-1).each do |x|
            txt = view.to_s(t2.getCell(x,y))
            next if (txt.nil?)
            while (txt.indexOf(sep)>=0) 
              sep = "-" + sep
            end
          end
        end
      end
      return sep
    end

    def quote_for_diff(v, d)
      nil_str = "nil"
      if (v.equals(d,nil)) 
        return nil_str
      end
      str = v.to_s(d)
      score = 0
      (0..str.length-1).each do |i| 
        break if (str.charCodeAt(score)!='_'.code)
        score+=1
      end
      if (str.substr(score)==nil_str) 
        str = "_" + str
      end
      return str
    end

    def is_reordered(m, ct) 
      reordered = false
      l = -1
      r = -1
      (0..ct-1).each do |i|
        unit = m[i]
        next if (unit.nil?)
        if (unit.l>=0) 
          if (unit.l<l) 
            reordered = true
            break
          end
          l = unit.l
        end
        if (unit.r>=0) 
          if (unit.r<r) 
            reordered = true
            break
          end
          r = unit.r
        end
      end
      return reordered
    end


    def spread_context(units, del, active) 
      if (del>0 && active != nil) 
        # forward
        mark = -del-1
        skips = 0
        (0..units.length-1).each do |i|
          if (active[i]==-3) 
            # inserted/deleted row that is not to be shown, ignore
            skips+=1
            next
          end
          if (active[i]==0||active[i]==3) 
            if (i-mark<=del+skips) 
              active[i] = 2
            elsif (i-mark==del+1+skips) 
              active[i] = 3
            end
          elsif (active[i]==1) 
            mark = i
            skips = 0
          end
        end
        
        # reverse
        mark = units.length + del + 1
        skips = 0
        (0..units.length-1).each do |j| 
          i = units.length-1-j
          if (active[i]==-3) 
            # inserted/deleted row that is not to be shown, ignore
            skips+=1
            next
          end
          if (active[i]==0||active[i]==3) 
            if (mark-i<=del+skips) 
              active[i] = 2
            elsif (mark-i==del+1+skips) 
              active[i] = 3
            end
          elsif (active[i]==1) 
            mark = i
            skips = 0
          end
        end
      end
    end

    def report_unit(unit)  
      txt  = unit.to_s
      reordered = false
      if (unit.l>=0) 
        if (unit.l<@l_prev) 
          reordered = true
        end
        @l_prev = unit.l
      end
      if (unit.r>=0) 
        if (unit.r<@r_prev) 
          reordered = true
        end
        @r_prev = unit.r
      end
      txt = "[" + txt + "]" if (reordered)
      return txt
    end

    def hilite(output)  
      return false if (!output.is_resizable?)
      output.resize(0,0)
      output.clear

      row_map = {}
      col_map = {}

      order = @align.to_order
      units = order.get_list
      has_parent = (@align.reference != nil)
      a = nil
      b = nil
      p = nil
      ra_header = 0
      rb_header = 0
      is_index_p = {}
      is_index_a = {}
      is_index_b = {}
      if (has_parent) 
        p = @align.get_source
        a = @align.reference.get_target
        b = @align.get_target
        ra_header = @align.reference.meta.get_target_header
        rb_header = @align.meta.get_target_header
        if (@align.get_index_columns) 
          @align.get_index_columns.each do |p2b| 
            is_index_p.set(p2b.l,true) if (p2b.l>=0) 
            is_index_b.set(p2b.r,true) if (p2b.r>=0) 
          end
        end
        if (@align.reference.get_index_columns) 
          @align.reference.get_index_columns.each do |p2a|
            is_index_p.set(p2a.l,true) if (p2a.l>=0) 
            is_index_a.set(p2a.r,true) if (p2a.r>=0)
          end
        end
      else 
        a = @align.get_source
        b = @align.get_target
        p = a
        ra_header = @align.meta.get_source_header
        rb_header = @align.meta.get_target_header
        if (@align.get_index_columns) 
          @align.get_index_columns.each do |a2b|
            is_index_a.set(a2b.l,true) if (a2b.l>=0) 
            is_index_b.set(a2b.r,true) if (a2b.r>=0)
          end
        end
      end

      column_order = @align.meta.to_order
      column_units = column_order.get_list

      show_rc_numbers = false
      row_moves = nil
      col_moves = nil
      if (@flags.ordered) 
        row_moves = {}
        moves = Mover.move_units(units)
        (0...moves.length).each do |i|
          row_moves[moves[i]] = i
        end
        col_moves = {}
        moves = Mover.move_units(column_units)
        (0...moves.length).each do |i|
          col_moves[moves[i]] = i
        end
      end

      active = []
      active_column = nil
      if (!@flags.show_unchanged) 
        (0...units.length).each do |i|
          active[i] = 0
        end
      end

      allow_insert = @flags.allow_insert
      allow_delete = @flags.allow_delete
      allow_update = @flags.allow_update

      if (!@flags.show_unchanged_columns) 
        active_column = []
        (0..column_units.length-1).each do |i| 
          v = 0
          unit = column_units[i]
          v = 1 if (unit.l>=0 && is_index_a.get(unit.l))
          v = 1 if (unit.r>=0 && is_index_b.get(unit.r))
          v = 1 if (unit.p>=0 && is_index_p.get(unit.p))
          active_column[i] = v
        end
      end

      outer_reps_needed = 
          (@flags.show_unchanged&&@flags.show_unchanged_columns) ? 1 : 2

      v = a.get_cell_view
      sep  = ""
      conflict_sep  = ""

      schema = []
      have_schema = false
      (0...column_units.length-1).each do |j|
        cunit = column_units[j]
        reordered = false

        if (@flags.ordered) 
          if (col_moves.exists(j)) 
            reordered = true
          end
          show_rc_numbers = true if (reordered) 
        end

        act  = ""
        if (cunit.r>=0 && cunit.lp==-1) 
          have_schema = true
          act = "+++"
          if (active_column) 
            active_column[j] = 1 if (allow_update) 
          end
        end
        if (cunit.r<0 && cunit.lp>=0) 
          have_schema = true
          act = "---"
          if (active_column) 
            active_column[j] = 1 if (allow_update) 
          end
        end
        if (cunit.r>=0 && cunit.lp>=0) 
          if (a.height>=ra_header && b.height>=rb_header) 
            aa = a.get_cell(cunit.lp,ra_header)
            bb = b.get_cell(cunit.r,rb_header)
            if (!v.equals(aa,bb)) 
              have_schema = true
              act = "("
              act += v.to_s(aa)
              act += ")"
              active_column[j] = 1 if (active_column)
            end
          end
        end
        if (reordered) 
          act = ":" + act
          have_schema = true
          active_column = nil if (active_column) # bail
        end

        schema << act
      end
      if (have_schema) 
        at = output.height
        output.resize(column_units.length+1,at+1)
        output.set_cell(0,at,v.to_datum("!"))
        (0..column_units.length-1).each do |j|
          output.set_cell(j+1,at,v.to_datum(schema[j]))
        end
      end

      top_line_done = false
      if (@flags.always_show_header) 
        at = output.height
        output.resize(column_units.length+1,at+1)
        output.set_cell(0,at,v.to_datum("@@"))
        (0...column_units.length-1).each do |j| 
          cunit = column_units[j]
          if (cunit.r>=0) 
            if (b.height>0) 
              output.set_cell(j+1,at,
               b.get_cell(cunit.r,rb_header))
            end
          elsif (cunit.lp>=0) 
            if (a.height>0) 
              output.set_cell(j+1,at,
               a.get_cell(cunit.lp,ra_header))
            end
          end
          col_map.set(j+1,cunit)
        end
        top_line_done = true
      end

        # If we are dropping unchanged rows/cols, we repeat this loop twice.
        (0..outer_reps_needed-1).each do |out| 
          if (out==1) 
            spread_context(units,@flags.unchanged_context,active)
            spread_context(column_units,@flags.unchanged_column_context,
              active_column)
            if (active_column) 
              (0..column_units.length).each do |i| 
                if (active_column[i]==3) 
                  active_column[i] = 0
                end
              end
            end
          end

          showed_dummy = false
          l = -1
          r = -1
          (0..units.length-1).each do |i| 
            unit = units[i]
            reordered = false

            if (@flags.ordered) 
              if (row_moves.has_key?(i)) 
                reordered = true
              end
              show_rc_numbers = true if (reordered)
            end

            next if (unit.r<0 && unit.l<0)

            next if (unit.r==0 && unit.lp==0 && top_line_done)

            act  = ""

            act = ":" if (reordered) 

            publish = @flags.show_unchanged
            dummy = false
            if (out==1) 
              publish = active[i]>0
              dummy = active[i]==3
              next if (dummy&&showed_dummy)
              next if (!publish)
            end

            showed_dummy = false if (!dummy)

            at = output.height
            if (publish) 
              output.resize(column_units.length+1,at+1)
            end

            if (dummy) 
              (0..(column_units.length+1)-1).each do |j| 
                output.set_cell(j,at,v.to_datum("..."))
                showed_dummy = true
              end
              next
            end

            have_addition = false
            skip = false

            if (unit.p<0 && unit.l<0 && unit.r>=0) 
              skip = true if (!allow_insert)
              act = "+++"
            end
            if ((unit.p>=0||!has_parent) && unit.l>=0 && unit.r<0) 
              skip = true if (!allow_delete)
              act = "---"
            end

            if (skip) 
              if (!publish) 
                if (active) 
                  active[i] = -3
                end
              end
              next
            end

            (0..column_units.length-1).each do |j| 
              cunit = column_units[j]
              pp = nil
              ll = nil
              rr = nil
              dd = nil
              dd_to = nil
              have_dd_to = false
              dd_to_alt = nil
              have_dd_to_alt = false
              have_pp = false
              have_ll = false
              have_rr = false
              if (cunit.p>=0 && unit.p>=0) 
                pp = p.get_cell(cunit.p,unit.p)
                have_pp = true
              end
              if (cunit.l>=0 && unit.l>=0) 
                ll = a.get_cell(cunit.l,unit.l)
                have_ll = true
              end
              if (cunit.r>=0 && unit.r>=0) 
                rr = b.get_cell(cunit.r,unit.r)
                have_rr = true
                if ((have_pp ? cunit.p : cunit.l)<0) 
                  if (rr != nil) 
                    if (v.to_s(rr) != "") 
                      if (@flags.allow_update) 
                        have_addition = true
                      end
                    end
                  end
                end
              end

              # for now, just interested in p->r
              if (have_pp) 
                if (!have_rr) 
                  dd = pp
                else 
                  # have_pp, have_rr
                  if (v.equals(pp,rr)) 
                    dd = pp
                  else 
                    # rr is different
                    dd = pp
                    dd_to = rr
                    have_dd_to = true

                    if (!v.equals(pp,ll)) 
                      if (!v.equals(pp,rr)) 
                        dd_to_alt = ll
                        have_dd_to_alt = true
                      end
                    end
                  end
                end
              elsif (have_ll) 
                if (!have_rr) 
                  dd = ll
                else 
                  if (v.equals(ll,rr)) 
                    dd = ll
                  else 
                    # rr is different
                    dd = ll
                    dd_to = rr
                    have_dd_to = true
                  end
                end
              else 
                dd = rr
              end

              txt  = nil
              if (have_dd_to&&allow_update) 
                if (active_column) 
                  active_column[j] = 1
                end
                txt = quoteForDiff(v,dd)
                # modification: x -> y
                if (sep=="") 
                  # strictly speaking getSeparator(a,nil,..)
                  # would be ok - but very confusing
                  sep = getSeparator(a,b,"->")
                end
                is_conflict = false
                if (have_dd_to_alt) 
                  if (!v.equals(dd_to,dd_to_alt)) 
                    is_conflict = true
                  end
                end
                if (!is_conflict) 
                  txt = txt + sep + quoteForDiff(v,dd_to)
                  if (sep.length>act.length) 
                    act = sep
                  end
                else 
                  if (conflict_sep=="") 
                    conflict_sep = getSeparator(p,a,"!") + sep
                  end
                  txt = txt + 
                  conflict_sep + quoteForDiff(v,dd_to_alt) +
                  conflict_sep + quoteForDiff(v,dd_to)
                  act = conflict_sep
                end
              end
              if (act == "" && have_addition) 
                act = "+"
              end
              if (act == "+++") 
                if (have_rr) 
                  if (active_column) 
                    active_column[j] = 1
                  end
                end
              end
              if (publish) 
                if (active_column.nil? || active_column[j]>0) 
                  if (txt != nil) 
                    output.setCell(j+1,at,v.toDatum(txt))
                  else 
                    output.setCell(j+1,at,dd)
                  end
                end
              end
            end

            if (publish) 
              output.set_cell(0,at,v.to_datum(act))
              row_map.set(at,unit)
            end
            if (act!="") 
              if (!publish) 
                if (active) 
                  active[i] = 1
                end
              end
            end
          end
        end

        # add row/col numbers?
        if (!show_rc_numbers) 
          if (@flags.always_show_order) 
            show_rc_numbers = true
          elsif (@flags.ordered) 
            show_rc_numbers = is_reordered(row_map,output.height)
            if (!show_rc_numbers) 
              show_rc_numbers = is_reordered(col_map,output.width)
            end
          end
        end

        admin_w = 1
        if (show_rc_numbers&&!@flags.never_show_order) 
            admin_w+=1
            target = new Array<Int>
            (0..output.width-1).each do |i| 
                target.push(i+1)
            end
            output.insert_or_delete_columns(target,output.width+1)
            @l_prev = -1
            @r_prev = -1
            (0..output.height-1).each do |i| 
                unit = row_map.get(i)
                next if (unit.nil?)
                output.setCell(0,i,reportUnit(unit))
            end
            target = []
            (0..output.height-1).each do |i|
                target.push(i+1)
            end
            output.insert_or_delete_rows(target,output.height+1)
            @l_prev = -1
            @r_prev = -1
            (1..output.width-1).each do |i| 
                unit = col_map.get(i-1)
                next if (unit.nil?)
                output.setCell(i,0,reportUnit(unit))
            end
            output.setCell(0,0,"@:@")
        end

        if (active_column) 
            all_active = true
            (0..active_column.length-1).each do |i| 
                if (active_column[i]==0) 
                    all_active = false
                    break
                end
            end
            if (!all_active) 
                fate = new Array<Int>
                (0..admin_w-1).each do |i| 
                    fate.push(i)
                end
                at = admin_w
                ct = 0
                dots = new Array<Int>
                (0..active_column.length-1).each do |i| 
                    off = (active_column[i]==0)
                    ct = off ? (ct+1) : 0
                    if (off && ct>1) 
                        fate.push(-1)
                    else 
                        dots.push(at) if (off)
                        fate.push(at)
                        at+=1
                    end
                end
                output.insertOrDeleteColumns(fate,at)
                dots.each do |d|
                    (0..output.height-1).each do |j| 
                        output.setCell(d,j,"...")
                    end
                end
            end
        end
        return true
    end
end
end
