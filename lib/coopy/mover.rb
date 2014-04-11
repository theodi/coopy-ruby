module Coopy
  class Mover 

    def self.move_units(units)
      isrc = []
      idest = []
      len = units.length
      ltop = -1.0
      rtop = -1
      in_src = {}
      in_dest  = {}
      (0..len-1).each do |i| 
        unit = units[i]
        if (unit.l>=0 && unit.r>=0) 
          ltop = unit.l if (ltop<unit.l) 
          rtop = unit.r if (rtop<unit.r)
          in_src[unit.l] = i
          in_dest[unit.r] = i
        end
      end
      v = nil
      (0...ltop+1).each do |i| 
        v = in_src[i]
        isrc.push(v) if v
      end
      (0...rtop+1).each do |i|
        v = in_dest[i]
        idest.push(v) if v
      end
      return move_without_extras(isrc,idest)
    end

    def self.move_with_extras(isrc, idest)
      # First pass: eliminate non-overlapping elements (inserts+deletes)
      len = isrc.length
      len2 = idest.length
      in_src = {}
      in_dest = {}
      (0..len-1).each do |i| 
        in_src[isrc[i]] = i
      end
      (0..len2-1).each do |i| 
        in_dest[idest[i]] = i
      end
      src = []
      dest = []
      v = nil
      (0..len-1).each do |i| 
        v = isrc[i]
        src << v if (in_dest.has_key?(v))
      end
      (0..len2-1).each do |i|
        v = idest[i]
        dest << v if (in_src.has_key?(v))
      end
      return move_without_extras(src,dest)
    end

    def self.move_without_extras(src, dest)
      return nil if (src.length!=dest.length) 
      return [] if (src.length<=1)
      
      len = src.length
      in_src = {}
      blk_len = {}
      blk_src_loc = {}
      blk_dest_loc = {}
      (0...len).each do |i|
        in_src[src[i]] = i
      end
      ct = 0
      in_cursor = -2
      out_cursor = 0
      nxt = nil
      blk = -1
      v = nil
      while (out_cursor<len)
        v = dest[out_cursor]
        nxt = in_src[v]
        if (nxt != in_cursor+1) 
          blk = v
          ct = 1
          blk_src_loc[blk] = nxt
          blk_dest_loc[blk] = out_cursor
        else 
          ct+=1
        end
        blk_len[blk] = ct
        in_cursor = nxt
        out_cursor+=1
      end

      blks = blk_len.keys
      blks.sort!{ |a,b| blk_len[a] <=> blk_len[b] }

      moved = []

      while (blks.length>0) 
        blk = blks.shift
        blen = blks.length
        ref_src_loc = blk_src_loc[blk]
        ref_dest_loc = blk_dest_loc[blk]
        i = blen-1
        while (i>=0) 
          blki = blks[i]
          blki_src_loc = blk_src_loc[blki]
          to_left_src = blki_src_loc < ref_src_loc
          to_left_dest = blk_dest_loc[blki] < ref_dest_loc
          if (to_left_src!=to_left_dest) 
            ct = blk_len[blki]
            (0..ct-1).each do |j| 
              moved.push(src[blki_src_loc])
              blki_src_loc+=1
            end
            blks.delete_at(i)
          end
          i-=1
        end
      end
      return moved
    end
  end
end
