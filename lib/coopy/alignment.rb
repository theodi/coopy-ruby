module Coopy
  class Alignment

    attr_accessor :reference # Alignment
    attr_accessor :meta # Alignment

    def initialize
      @map_a2b = {} # Map<Int,Int>
      @map_b2a = {} # Map<Int,Int>
      @ha = @hb = 0
      @map_count = 0
      @reference = nil
      @meta = nil
      @order_cache_has_reference = false
      @ia = 0
      @ib = 0
    end

    def range(ha, hb)
      @ha = ha
      @hb = hb
    end

    def tables(ta, tb)
      @ta = ta
      @tb = tb
    end

    def headers(ia, ib)
      @ia = ia
      @ib = ib
    end

    def setRowlike(flag)
    end

    def link(a, b)
      @map_a2b.set(a,b)
      @map_b2a.set(b,a)
      @map_count+=1
    end

    def add_index_columns(unit)
      if @index_columns.nil?
        @index_columns = []
      end
      @index_columns << unit
    end

    def get_index_columns
      @index_columns
    end

    def a2b(a)
      @map_a2b.get(a)
    end

    def b2a(b)
      @map_b2a.get(b)
    end

    def count
      @map_count
    end

    def to_s
      map_a2b.to_s
    end

    def to_order
      if @order_cache
        if @reference
          if !@order_cache_has_reference
            @order_cache = nil
          end
        end
      end
      @order_cache = to_order_3 if @order_cache.nil?
      @order_cache_has_reference = true if reference
      @order_cache
    end

    def get_source
      @ta
    end

    def get_target
      @tb
    end

    def get_source_header
      @ia
    end

    def get_target_header
      @ib
    end

    def to_order_3
      ref = @reference
      if ref.nil?
        ref = Coopy::Alignment.new
        ref.range(@ha,@ha)
        ref.tables(@ta,@ta)
        0..@ha-1.each do |i|
          ref.link(i,i)
        end
      end
      order = Coopy::Ordering.new
      if @reference.nil?
        order.ignore_parent
      end
      xp = 0
      xl = 0
      xr = 0
      hp = @ha
      hl = ref.hb
      hr = @hb
      vp = {}
      vl = {}
      vr = {}
      0..hp-1.each { |i| vp.set(i,i) }
      0..hl-1.each { |i| vl.set(i,i) }
      0..hr-1.each { |i| vr.set(i,i) }
      ct_vp = hp
      ct_vl = hl
      ct_vr = hr
      prev  = -1
      ct    = 0
      max_ct = (hp+hl+hr)*10
      while (ct_vp>0 || 
             ct_vl>0 || 
             ct_vr>0) do
        ct+=1
        if ct>max_ct
          puts("Ordering took too long, something went wrong")
          break
        end
        xp = 0 if (xp>=hp)
        xl = 0 if (xl>=hl)
        xr = 0 if (xr>=hr)
        if xp<hp && ct_vp>0
          if a2b(xp).nil? && ref.a2b(xp).nil?
            if vp.has_key?(xp)
              order.add(-1,-1,xp)
              prev = xp
              vp.remove(xp)
              ct_vp-=1
            end
            xp+=1
            next
          end
        end
        zl = nil
        zr = nil
        if xl<hl && ct_vl>0
          zl = ref.b2a(xl)
          if zl.nil?
            if vl.has_key?(xl)
              order.add(xl,-1,-1)
              vl.remove(xl)
              ct_vl-=1
            end
            xl+=1
            next
          end
        end
        if xr<hr && ct_vr>0
          zr = b2a(xr)
          if zr.nil?
            if vr.has_key?(xr)
              order.add(-1,xr,-1)
              vr.remove(xr)
               ct_vr-=1
            end
            xr+=1
            next
          end
        end
        if zl
          if a2b(zl).nil?
            # row deleted in remote
            if vl.has_key?(xl)
              order.add(xl,-1,zl)
              prev = zl
              vp.remove(zl)
              ct_vp-=1
              vl.remove(xl)
              ct_vl-=1
              xp = zl+1
            end
            xl+=1
            next
          end
        end
        if zr
          if ref.a2b(zr).nil?
            # row deleted in local
            if vr.has_key?(xr)
              order.add(-1,xr,zr)
              prev = zr
              vp.remove(zr)
              ct_vp-=1
              vr.remove(xr)
              ct_vr-=1
              xp = zr+1
            end
            xr+=1
            next
          end
        end
        if zl && zr && a2b(zl) && ref.a2b(zr)
          # we have a choice of order
          # local thinks zl should come next
          # remote thinks zr should come next
          if zl==prev+1 || zr!=prev+1
            if vr.has_key?(xr)
              order.add(ref.a2b(zr),xr,zr)
              prev = zr
              vp.remove(zr)
              ct_vp-=1
              vl.remove(ref.a2b(zr))
              ct_vl-=1
              vr.remove(xr)
              ct_vr-=1
              xp = zr+1
              xl = ref.a2b(zr)+1
            end
            xr+=1
            next
          else
            if vl.has_key?(xl)
              order.add(xl,a2b(zl),zl)
              prev = zl
              vp.remove(zl)
              ct_vp-=1
              vl.remove(xl)
              ct_vl-=1
              vr.remove(a2b(zl))
              ct_vr-=1
              xp = zl+1
              xr = a2b(zl)+1
            end
            xl+=1
            next
          end
        end
        xp+=1
        xl+=1
        xr+=1
      end
      return order
    end

  end
end
