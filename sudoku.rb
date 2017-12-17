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
    puts "Entropy: #{self.entropy} (min=81|max=#{9*9*9})"
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
    puts "Entropy: #{self.entropy} (min=81|max=#{9*9*9})"
  end

  def reduce_line
    solved = self.to_field
    (1..9).to_a.each do |col|
      items = solved.field[col-1].select{|item| item != 0}
      reduce_single_line(col, items)
    end
    self
  end

  def reduce_col
    solved = self.to_field_transpose
    (1..9).to_a.each do |line|
      items = solved.field[line-1].select{|item| item != 0}
      reduce_single_col(line, items)
    end
    self
  end

  def reduce_hidden_single
    (1..9).to_a.each do |line|
      solutions = to_field
      find_single_in_line(line, solutions.field[line-1])
    end
    (1..9).to_a.each do |col|
      solutions = to_field_transpose
      find_single_in_col(col, solutions.field[col-1])
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

  def reduce_single_line(col, items)
    (1..9).to_a.each do |line|
      @field[col][line] -= items if @field[col][line].size > 1
    end
  end

  def reduce_single_col(line, items)
    (1..9).to_a.each do |col|
      @field[col][line] -= items if @field[col][line].size > 1
    end
  end

  def find_single_in_line(line, solution_line)
    statistics = {}
    (1..9).to_a.each do |col|
      @field[line][col].each do |item|
        statistics[item] = (statistics[item]||0) + 1
      end
    end
    new_solutions = statistics.select{|key,value| value == 1}.select{|key,value| !solution_line.include?(key)}
    new_solutions.each do |key, _|
      (1..9).to_a.each do |col|
        @field[line][col] = [key] if @field[line][col].include?(key)
      end
    end
    puts "found new 'hidden_single' in line(#{line}): #{new_solutions}" if new_solutions.size > 0
    reduce_single_line(line, new_solutions.keys) if new_solutions.size > 0
    self
  end

  def find_single_in_col(col, solution_line)
    statistics = {}
    (1..9).to_a.each do |line|
      @field[line][col].each do |item|
        statistics[item] = (statistics[item]||0) + 1
      end
    end
    new_solutions = statistics.select{|key,value| value == 1}.select{|key,value| !solution_line.include?(key)}
    new_solutions.each do |key, _|
      (1..9).to_a.each do |line|
        @field[line][col] = [key] if @field[line][col].include?(key)
      end
    end
    puts "found new 'hidden_single' in col(#{col}): #{new_solutions}" if new_solutions.size > 0
    reduce_single_col(col, new_solutions.keys) if new_solutions.size > 0
    self
  end


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
    reduce_single_col_grid_gap(a, b, solved_cols(a+1, a+2, b))
    reduce_single_col_grid_gap(a+1, b, solved_cols(a, a+2, b))
    reduce_single_col_grid_gap(a+2, b, solved_cols(a, a+1, b))
  end

  def reduce_single_col_grid_gap(a,b,items)
    ((1..9).to_a-b).each do |col|
      @field[col][a] -= items if @field[col][a].size > 1
    end
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

  def reduce_single_line_grid(grid_col, grid_line)
    a = (grid_col-1)*3+1
    b = (((grid_line-1)*3+1)..((grid_line)*3)).to_a
    reduce_single_line_grid_gap(a, b, solved_lines(a+1, a+2, b))
    reduce_single_line_grid_gap(a+1, b, solved_lines(a, a+2, b))
    reduce_single_line_grid_gap(a+2, b, solved_lines(a, a+1, b))
  end

  def reduce_single_line_grid_gap(a,b,items)
    ((1..9).to_a-b).each do |line|
      @field[a][line] -= items if @field[a][line].size > 1
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

  def entropy
    sum = 0
    iterator((1..9)) { |col, line|
      sum += @field[col][line].size
    }
    sum
  end

  def to_field
    SudokuField.new.solved(@field)
  end

  def to_field_transpose
    SudokuField.new.solved_transpose(@field)
  end
end
