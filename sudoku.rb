class Sudoku
  attr_accessor :field

  def initialize(init_field = nil)
    @field = {}
    iterator((1..9)){|col,line|
      @field[col] ||= {}
      @field[col] = @field[col].merge({line => (1..9).to_a})
      unless init_field.nil?
        @field[col][line] = [init_field.field[col-1][line-1]] unless init_field.field[col-1][line-1] == 0
      end
    }
  end

  def inspect
    to_s
  end

  def to_s
    (1..9).to_a.each do |col|
      (1..9).to_a.each do |line|
        print "{#{@field[col][line].size > 1 ? '?'+@field[col][line].size.to_s+'?' : '_'+@field[col][line].first.to_s+'_' }}"
        print "  " if line % 3 == 0
      end
      puts ""  if col % 3 == 0
      puts ""
    end
  end

  def to_s_t
    (1..9).to_a.each do |col|
      (1..9).to_a.each do |line|
        print "{#{@field[line][col].size > 1 ? '?'+@field[line][col].size.to_s+'?' : '_'+@field[line][col].first.to_s+'_' }}"
        print "  " if line % 3 == 0
      end
      puts ""  if col % 3 == 0
      puts ""
    end
  end

  def reduce_line
    solved = self.to_field
    (1..9).to_a.each do |col|
      items = solved.field[col-1].select{|item| item != 0}
      (1..9).to_a.each do |line|
        @field[col][line] -= items if @field[col][line].size > 1
      end
    end
    self
  end

  def reduce_col
    solved = self.to_field_transpose
    (1..9).to_a.each do |line|
      items = solved.field[line-1].select{|item| item != 0}
      (1..9).to_a.each do |col|
        @field[col][line] -= items if @field[col][line].size > 1
      end
    end
    self
  end

  def reduce_grid
    iterator((1..3)){|col,line|
      reduce_single_grid(col, line, solved_grid(col, line).flatten)
      scan_single_grid(col,line, solved_grid(col, line).flatten)
    }
    self
  end

  def reduce_advance_scan
    iterator((1..3)){|col,line| advanced_scan_grid(col,line) }
    self
  end

  def reduce_line_grid
    iterator((1..3)){|col,line| reduce_single_line_grid(col, line) }
    self
  end

  def reduce_col_grid
    iterator((1..3)){|col,line| reduce_single_col_grid(col,line) }
    self
  end

  def iterator(range)
    range.to_a.each do |col|
      range.to_a.each do |line|
        yield(col, line)
      end
    end
  end

#private
  def advanced_scan_grid(grid_col, grid_line)
    col_off = (grid_col-1)*3
    line_off = (grid_line-1)*3

    ((1..3).to_a-[grid_col]).each do |col|
      uniq_col = uniq_in_col(col, grid_line)
      (1..3).to_a.each do |cols|
        @field[col_off+cols][line_off+1] -= uniq_col[1] if @field[col_off+cols][line_off+1].size > 1
        @field[col_off+cols][line_off+2] -= uniq_col[2] if @field[col_off+cols][line_off+2].size > 1
        @field[col_off+cols][line_off+3] -= uniq_col[3] if @field[col_off+cols][line_off+3].size > 1
      end
    end

    ((1..3).to_a-[grid_line]).each do |line|
      uniq_line = uniq_in_line(grid_col, line)
      (1..3).to_a.each do |lines|
        @field[col_off+1][line_off+lines] -= uniq_line[1] if @field[col_off+1][line_off+lines].size > 1
        @field[col_off+2][line_off+lines] -= uniq_line[2] if @field[col_off+2][line_off+lines].size > 1
        @field[col_off+3][line_off+lines] -= uniq_line[3] if @field[col_off+3][line_off+lines].size > 1
      end
    end

    self
  end

  def uniq_in_col(grid_col, grid_line)
    col_off = (grid_col-1)*3
    line_off = (grid_line-1)*3
    columns = {1=>[], 2=>[], 3=>[]}
    (1..3).to_a.each do |line|
      columns[line].push(@field[col_off+1][line_off+line])
      columns[line].push(@field[col_off+2][line_off+line])
      columns[line].push(@field[col_off+3][line_off+line])
    end

    columns.each do |key,item|
      columns[key] = item.flatten.uniq
    end
    uniq_in_column = {1=>[], 2=>[], 3=>[]}
    uniq_in_column[1] = columns[1]-columns[2]-columns[3]
    uniq_in_column[2] = columns[2]-columns[1]-columns[3]
    uniq_in_column[3] = columns[3]-columns[1]-columns[2]
    uniq_in_column
  end

  def uniq_in_line(grid_col, grid_line)
    col_off = (grid_col-1)*3
    line_off = (grid_line-1)*3
    lines = {1=>[], 2=>[], 3=>[]}
    (1..3).to_a.each do |col|
      lines[col].push(@field[col_off+col][line_off+1])
      lines[col].push(@field[col_off+col][line_off+2])
      lines[col].push(@field[col_off+col][line_off+3])
    end

    lines.each do |key,item|
      lines[key] = item.flatten.uniq
    end

    uniq_in_line = {1=>[], 2=>[], 3=>[]}
    uniq_in_line[1] = lines[1]-lines[2]-lines[3]
    uniq_in_line[2] = lines[2]-lines[1]-lines[3]
    uniq_in_line[3] = lines[3]-lines[1]-lines[2]
    uniq_in_line
  end

  def scan_single_grid(col,line, solved_items)
    col_off = (col-1)*3
    line_off = (line-1)*3
    statistics = {}
    iterator((1..3)){|col,line|
      @field[col_off+col][line_off+line].each do |item|
        statistics[item] = (statistics[item]||0) + 1
      end
    }
    single_pos_items = statistics.select{|key,item| item == 1}.keys
    new_solved_item = single_pos_items-solved_items
    new_solved_item.each do |found_item|
      iterator((1..3)){|col,line|
        @field[col_off+col][line_off+line] = [found_item] if @field[col_off+col][line_off+line].include?(found_item)
      }
    end
  end

  def solved_grid(a,b)
    data = []
    (0..8).to_a.map{|item| data[item] = []}
    iterator((0..2)){|col,line|
      data[col][line] = @field[1+(a-1)*3+col][1+(b-1)*3+line].size > 1 ? 0 : @field[1+(a-1)*3+col][1+(b-1)*3+line].first
    }
    data
  end

  def reduce_single_grid(a,b,items)
    iterator((0..2)){|col,line|
      @field[1+(a-1)*3+col][1+(b-1)*3+line] -= items if @field[1+(a-1)*3+col][1+(b-1)*3+line].size > 1
    }
    self
  end

  def reduce_single_col_grid(grid_col, grid_line)
    a = (grid_col-1)*3+1
    b = (((grid_line-1)*3+1)..((grid_line)*3)).to_a
    reduce_single_col(a, b, solved_cols(a+1, a+2, b))
    reduce_single_col(a+1, b, solved_cols(a, a+2, b))
    reduce_single_col(a+2, b, solved_cols(a, a+1, b))
  end

  def reduce_single_line_grid(grid_col, grid_line)
    a = (grid_col-1)*3+1
    b = (((grid_line-1)*3+1)..((grid_line)*3)).to_a
    reduce_single_line(a, b, solved_lines(a+1, a+2, b))
    reduce_single_line(a+1, b, solved_lines(a, a+2, b))
    reduce_single_line(a+2, b, solved_lines(a, a+1, b))
  end

  def reduce_single_line(a,b,items)
    ((1..9).to_a-b).each do |line|
      @field[a][line] -= items if @field[a][line].size > 1
    end
  end

  def reduce_single_col(a,b,items)
    ((1..9).to_a-b).each do |col|
      @field[col][a] -= items if @field[col][a].size > 1
    end
  end

  def solved_lines(a,b,indexes)
    solutions = to_field
    cols = (1..9).to_a - indexes
    line_a = []
    line_b = []
    cols.each do |col_index|
      line_a.push(solutions.field[a-1][col_index-1]) if solutions.field[a-1][col_index-1] != 0
      line_b.push(solutions.field[b-1][col_index-1]) if solutions.field[b-1][col_index-1] != 0
    end
    line_a.select{|item| line_b.include?(item)} || []
  end

  def solved_cols(a,b,indexes)
    solutions = to_field_transpose
    lines = (1..9).to_a - indexes
    col_a = []
    col_b = []
    lines.each do |line_index|
      col_a.push(solutions.field[a-1][line_index-1]) if solutions.field[a-1][line_index-1] != 0
      col_b.push(solutions.field[b-1][line_index-1]) if solutions.field[b-1][line_index-1] != 0
    end
    col_a.select{|item| col_b.include?(item)} || []
  end

  def to_field
    SudokuField.new.solved(@field)
  end

  def to_field_transpose
    SudokuField.new.solved_transpose(@field)
  end
end


class SudokuField
  attr_accessor :field

  def initialize(default = nil)
    @field = (0..8).to_a.map{|item| (0..8).to_a.map{|i| 0}}
    case default
    when nil
    when :easy
      self.easy
    when :hard
      self.hard
    when :evil
      self.evil
    end
  end

  def solved?
    !field.flatten.include?(0)
  end

  def solved(field)
    (1..9).to_a.each do |col|
      (1..9).to_a. each do |line|
        @field[col-1][line-1] = field[col][line].size > 1 ? 0 : field[col][line].first
      end
    end
    self
  end

  def solved_transpose(field)
    (1..9).to_a.each do |col|
      (1..9).to_a. each do |line|
        @field[line-1][col-1] = field[col][line].size > 1 ? 0 : field[col][line].first
      end
    end
    self
  end

  def to_s
    print "[\n"
    (0..8).to_a.each do |col|
      print '['
      (0..8).to_a.each do |line|
        print " #{@field[col][line]}"
      end
      print "]\n"
    end
    print "]"
  end

  def easy
    @field[0] = [ 3, 4, 7, 9, 2, 6, 0, 1, 0 ]
    @field[1] = [ 0, 0, 0, 0, 0, 0, 6, 0, 3 ]
    @field[2] = [ 0, 0, 6, 1, 0, 0, 0, 4, 9 ]
    @field[3] = [ 0, 0, 0, 3, 5, 0, 0, 0, 0 ]
    @field[4] = [ 4, 1, 0, 7, 0, 2, 0, 3, 8 ]
    @field[5] = [ 0, 0, 0, 0, 9, 4, 0, 0, 0 ]
    @field[6] = [ 1, 7, 0, 0, 0, 8, 2, 0, 0 ]
    @field[7] = [ 5, 0, 4, 0, 0, 0, 0, 0, 0 ]
    @field[8] = [ 0, 9, 0, 2, 3, 7, 4, 5, 1 ]
    true
  end

  def hard
    @field[0] = [ 4, 0, 0, 0, 0, 0, 7, 9, 0 ]
    @field[1] = [ 0, 6, 9, 0, 1, 0, 4, 0, 0 ]
    @field[2] = [ 0, 0, 0, 9, 0, 0, 5, 0, 0 ]
    @field[3] = [ 6, 0, 0, 8, 0, 4, 0, 0, 0 ]
    @field[4] = [ 0, 9, 0, 3, 0, 1, 0, 6, 0 ]
    @field[5] = [ 0, 0, 0, 2, 0, 5, 0, 0, 9 ]
    @field[6] = [ 0, 0, 7, 0, 0, 8, 0, 0, 0 ]
    @field[7] = [ 0, 0, 1, 0, 5, 0, 3, 2, 0 ]
    @field[8] = [ 0, 5, 6, 0, 0, 0, 0, 0, 8 ]

    # @field[0] = [ 0, 2, 6, 0, 0, 3, 0, 0, 0 ]
    # @field[1] = [ 0, 0, 0, 6, 8, 0, 0, 0, 3 ]
    # @field[2] = [ 0, 3, 9, 0, 0, 0, 0, 0, 0 ]
    # @field[3] = [ 0, 0, 5, 0, 0, 8, 3, 7, 0 ]
    # @field[4] = [ 0, 0, 0, 1, 6, 4, 0, 0, 0 ]
    # @field[5] = [ 0, 4, 2, 5, 0, 0, 8, 0, 0 ]
    # @field[6] = [ 0, 0, 0, 0, 0, 0, 7, 8, 0 ]
    # @field[7] = [ 6, 0, 0, 0, 2, 5, 0, 0, 0 ]
    # @field[8] = [ 0, 0, 0, 9, 0, 0, 6, 2, 0 ]
    true
  end

  def evil
    @field[0] = [ 0, 3, 0, 0, 1, 0, 0, 7, 0 ]
    @field[1] = [ 0, 0, 0, 6, 0, 3, 1, 0, 2 ]
    @field[2] = [ 6, 0, 0, 0, 0, 0, 0, 0, 0 ]
    @field[3] = [ 0, 2, 4, 0, 0, 7, 0, 0, 3 ]
    @field[4] = [ 0, 0, 0, 0, 6, 0, 0, 0, 0 ]
    @field[5] = [ 1, 0, 0, 5, 0, 0, 8, 4, 0 ]
    @field[6] = [ 0, 0, 0, 0, 0, 0, 0, 0, 5 ]
    @field[7] = [ 2, 0, 1, 3, 0, 4, 0, 0, 0 ]
    @field[8] = [ 0, 4, 0, 0, 9, 0, 0, 8, 0 ]
    true
  end

end
