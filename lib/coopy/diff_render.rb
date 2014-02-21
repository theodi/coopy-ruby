# encoding: utf-8

module Coopy
  class DiffRender 

    def initialize  
        @text_to_insert = []
        @open = false
        @pretty_arrows = true
    end

    def use_pretty_arrows(flag)  
        @pretty_arrows = flag
    end

    def insert(str)  
        @text_to_insert.push(str)
    end

    def begin_table()  
        insert("<table>\n")
    end

    def begin_row(mode)  
        @td_open = '<td'
        @td_close = '</td>'
        row_class = ""
        if (mode=="header") 
            @td_open = "<th"
            @td_close = "</th>"
        else 
            row_class = mode
        end
        tr = "<tr>"
        if (row_class!="") 
            tr = "<tr class=\"" + row_class + "\">"
        end
        insert(tr)
    end

    def insert_cell(txt, mode)  
        cell_decorate = ""
        if (mode!="") 
            cell_decorate = " class=\"" + mode + "\""
        end
        insert(@td_open+cell_decorate+">")
        insert(txt)
        insert(@td_close)
    end

    def end_row() 
        insert("</tr>\n")
    end

    def end_table()  
        insert("</table>\n")
    end

    def html() 
        return @text_to_insert.join('')
    end

    def to_s() 
        return html()
    end


    def self.examine_cell(x, y, value, vcol, vrow, vcorner, cell)  
        cell.category = ""
        cell.category_given_tr = ""
        cell.separator = ""
        cell.conflicted = false
        cell.updated = false
        cell.pvalue = cell.lvalue = cell.rvalue = nil
        cell.value = value
        cell.value = "" if (cell.value.nil?) 
        cell.pretty_value = cell.value
        vrow = "" if (vrow.nil?)
        vcol = "" if (vcol.nil?)
        removed_column = false
        if (vrow == ":") 
            cell.category = 'move'
        end 
        if (vcol.index("+++")) 
            cell.category_given_tr = cell.category = 'add'
        elsif (vcol.index("---")) 
            cell.category_given_tr = cell.category = 'remove'
            removed_column = true
        end
        if (vrow == "!") 
            cell.category = 'spec'
        elsif (vrow == "@@") 
            cell.category = 'header'
        elsif (vrow == "+++") 
            if (!removed_column) 
                cell.category = 'add'
            end
        elsif (vrow == "---") 
            cell.category = "remove"
        elsif (vrow.index("->")) 
            if (!removed_column) 
                tokens = vrow.split("!")
                full = vrow
                part = tokens[1]
                part = full if (part.nil?)
                if (cell.value.index(part)) 
                    cat = "modify"
                    div = part
                    # render with utf8 -> symbol
                    if (part!=full) 
                        if (cell.value.index(full)) 
                            div = full
                            cat = "conflict"
                            cell.conflicted = true
                        end
                    end
                    cell.updated = true
                    cell.separator = div
                    tokens = cell.pretty_value.split(div)
                    pretty_tokens = tokens
                    if (tokens.length>=2) 
                        pretty_tokens[0] = mark_spaces(tokens[0],tokens[1])
                        pretty_tokens[1] = mark_spaces(tokens[1],tokens[0])
                    end
                    if (tokens.length>=3) 
                        ref = pretty_tokens[0]
                        pretty_tokens[0] = mark_spaces(ref,tokens[2])
                        pretty_tokens[2] = mark_spaces(tokens[2],ref)
                    end
                    if (tokens.length == 0)
                        pretty_tokens = ['','']
                    end
                    cell.pretty_value = pretty_tokens.join("→")
                    cell.category_given_tr = cell.category = cat
                    offset = cell.conflicted ? 1 : 0
                    cell.lvalue = tokens[offset]
                    cell.rvalue = tokens[offset+1]
                    cell.pvalue = tokens[0] if (cell.conflicted)
                end
            end
        end
    end

    def self.mark_spaces(sl, sr) 
        return sl if (sl==sr)
        return sl if (sl.nil? || sr.nil?)
        slc = sl.gsub(" ","")
        src = sr.gsub(" ","")
        return sl if (slc!=src)
        slo = ""
        il = 0
        ir = 0
        while (il<sl.length) 
            cl = sl[il]
            cr = ""
            if (ir<sr.length) 
                cr = sr[ir]
            end
            if (cl==cr) 
                slo += cl
                il+=1
                ir+=1
            elsif (cr==" ") 
                ir+=1
            else 
                slo += " " # this is U+2423, open box
                il+=1
            end
        end
        return slo
    end

    def self.render_cell(tt, x, y)
        cell = Coopy::CellInfo.new
        corner = tt.get_cell_text(0,0)
        off = (corner=="@:@") ? 1 : 0

        examine_cell(x,
                    y,
                    tt.get_cell_text(x,y),
                    tt.get_cell_text(x,off),
                    tt.get_cell_text(off,y),
                    corner,
                    cell)
        return cell
    end

    def render(rows) 
        return if (rows.width==0||rows.height==0)
        render = self
        render.begin_table()
        change_row = -1
        tt = Coopy::TableText.new(rows)
        cell = CellInfo.new
        corner = tt.get_cell_text(0,0)
        off = (corner=="@:@") ? 1 : 0
        if (off>0) 
            return if (rows.width<=1||rows.height<=1)
        end
        (0...rows.height).each do |row| 

            @open = false

            txt = tt.get_cell_text(off,row)
            txt = "" if (txt.nil?)
            DiffRender.examine_cell(0,row,txt,"",txt,corner,cell)
            row_mode = cell.category
            if (row_mode == "spec") 
                change_row = row
            end

            render.begin_row(row_mode)

            (0...rows.width).each do |c|
                DiffRender.examine_cell(c,
                            row,
                            tt.get_cell_text(c,row),
                            (change_row>=0)?tt.get_cell_text(c,change_row):"",
                            txt,
                            corner,
                            cell)
                render.insert_cell(@pretty_arrows ? cell.pretty_value : cell.value,
                                  cell.category_given_tr)
            end
            render.end_row()
        end
        render.end_table()
    end

    def sample_css() 
        return ".highlighter .add  
  background-color: #7fff7f
end

.highlighter .remove  
  background-color: #ff7f7f
end

.highlighter td.modify  
  background-color: #7f7fff
end

.highlighter td.conflict  
  background-color: #f00
end

.highlighter .spec  
  background-color: #aaa
end

.highlighter .move  
  background-color: #ffa
end

.highlighter .nil  
  color: #888
end

.highlighter table  
  border-collapse:collapse
end

.highlighter td, .highlighter th 
  border: 1px solid #2D4068
  padding: 3px 7px 2px
end

.highlighter th, .highlighter .header  
  background-color: #aaf
  font-weight: bold
  padding-bottom: 4px
  padding-top: 5px
  text-align:left
end

.highlighter tr:first-child td 
  border-top: 1px solid #2D4068
end

.highlighter td:first-child  
  border-left: 1px solid #2D4068
end

.highlighter td 
  empty-cells: show
end
"
    end

    def completeHtml()  
        @text_to_insert.insert(0,"<html>
<meta charset='utf-8'>
<head>
<style TYPE='text/css'>
")
        @text_to_insert.insert(1,sample_css())
        @text_to_insert.insert(2,"</style>
</head>
<body>
<div class='highlighter'>
")
        @text_to_insert.push("</div>
</body>
</html>
")
    end
  end
end

