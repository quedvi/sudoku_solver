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

  def solve
    step = 0
    until to_field.solved?
      reduce_solved
      find_single_hidden
      reduce_solved
      find_pair
      reduce_solved
      find_claiming_pair
      reduce_solved

      # reduce_line_grid
      # reduce_col_grid
      # reduce_advance_scan
      step +=1
      break if step % 50 == 0
    end
    puts "solved in #{step} steps.\n" if to_field.solved?
    puts "not solved \n" if step >= 50
    self
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
    puts "Entropy: #{self.entropy}    (min=81|max=#{9*9*9})"
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

  # reduce possibilities by numbers already determined
  def reduce_solved
    before = 9*9*9
    after = entropy
    while before > after
      before = after
      reduce_line
      reduce_col
      reduce_grid
      after = entropy
    end
    self
  end

  # find numbers that can only be on one position (hidden in other solutions)
  def find_single_hidden
    before = self.entropy
    reduce_hidden_single_line
    reduce_hidden_single_col
    reduce_hidden_single_grid
    reduce_solved if before > self.entropy
  end

  # find 2 equal number-pairs in one line/col/grid
  # -> reduce these numbers from the respective line/col/grid
  def find_pair
    before = self.entropy
    reduce_pair_line
    reduce_pair_col
    reduce_pair_grid
    reduce_solved if before > self.entropy
    self
  end

  # find 2/3 appearances of an unsolved number in a single grid aligned in one row/col
  # where this number can not be solved outside this grid
  def find_claiming_pair
    iterator((1..3)){|col,line|
      scan_claiming_pair_line(col,line)
      reduce_solved
      scan_claiming_pair_col(col,line)
      reduce_solved
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

  def reduce_line
    solved = self.to_field
    (1..9).to_a.each do |line|
      items = solved.field[line-1].select{|item| item != 0}
      reduce_single_line(line, items)
    end
  end

  def reduce_col
    solved = self.to_field_transpose
    (1..9).to_a.each do |col|
      items = solved.field[col-1].select{|item| item != 0}
      reduce_single_col(col, items)
    end
  end

  def reduce_grid
    iterator((1..3)){|col,line|
      reduce_single_grid(col, line, solved_grid(col, line).flatten)
      scan_single_grid(col,line, solved_grid(col, line).flatten)
    }
  end

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

  def reduce_hidden_single_line
    (1..9).to_a.each do |line|
      solutions = to_field
      find_single_in_line(line, solutions.field[line-1])
    end
  end

  def reduce_hidden_single_col
    (1..9).to_a.each do |col|
      solutions = to_field_transpose
      find_single_in_col(col, solutions.field[col-1])
    end
  end

  def reduce_hidden_single_grid
    iterator((1..3)) { |col, line|
      find_single_in_grid(col,line)
    }
  end

  def find_single_in_line(line, solution_line)
    statistics = statistics_line(line)
    new_solutions = statistics.select{|key,value| value == 1}.select{|key,value| !solution_line.include?(key)}
    new_solutions.each do |key, _|
      (1..9).to_a.each do |col|
        @field[line][col] = [key] if @field[line][col].include?(key)
      end
    end
    reduce_single_line(line, new_solutions.keys) if new_solutions.size > 0
    self
  end

  def find_single_in_col(col, solution_line)
    statistics = statistics_col(col)
    new_solutions = statistics.select{|key,value| value == 1}.select{|key,value| !solution_line.include?(key)}
    new_solutions.each do |key, _|
      (1..9).to_a.each do |line|
        @field[line][col] = [key] if @field[line][col].include?(key)
      end
    end
    reduce_single_col(col, new_solutions.keys) if new_solutions.size > 0
    self
  end

  def find_single_in_grid(col, line)
    col_off = (col-1)*3
    line_off = (line-1)*3
    statistics = statistics_grid(col,line)
    old_solutions = solutions_grid(col,line)
    return if old_solutions.size == 9 # grid already solved
    new_solutions = statistics.select{|key,value| value == 1}.select{|key,value| !old_solutions.include?(key)}
    new_solutions.each do |key, _|
      iterator((1..3)){ |col, line|
        @field[col_off+col][line_off+line] = [key] if @field[col_off+col][line_off+line].include?(key)
      }
    end
    reduce_single_grid(col,line, new_solutions.keys) if new_solutions.size > 0
    self
  end

  def reduce_pair_line
    (1..9).to_a.each do |line|
      find_pair_line(line)
    end
  end

  def reduce_pair_col
    (1..9).to_a.each do |col|
      find_pair_col(col)
    end
  end

  def reduce_pair_grid
    iterator((1..3)){ |line,col|
      find_pair_grid(line,col)
    }
  end

  def find_pair_line(line)
    pairs = @field[line].select{|key,value| value.size == 2}
    return if pairs.size < 2
    doubles = double_pairs(pairs)
    doubles.each do |pair|
      (1..9).to_a.each do |col|
        @field[line][col] -= pair unless @field[line][col] == pair
      end
    end
  end

  def find_pair_col(col)
    pairs = {}
    (1..9).to_a.each do |line|
      pairs[line] = @field[line][col] if @field[line][col].size == 2
    end
    return if pairs.size < 2
    doubles = double_pairs(pairs)
    doubles.each do |pair|
      (1..9).to_a.each do |line|
        @field[line][col] -= pair unless @field[line][col] == pair
      end
    end
  end

  def find_pair_grid(line,col)
    col_off = (col-1)*3
    line_off = (line-1)*3
    pairs = {}
    iterator((1..3)){ |line, col|
      pairs[(line-1)*3+col] = @field[line_off+line][col_off+col] if @field[line_off+line][col_off+col].size == 2
    }
    doubles = double_pairs(pairs)
    doubles.each do |pair|
      iterator((1..3)){ |line,col|
        @field[line_off+line][col_off+col] -= pair unless @field[line_off+line][col_off+col] == pair
      }
    end
  end

  def double_pairs(pairs)
    doubles = []
    pairs.each do |keya, valuea|
      pairs.each do |keyb, valueb|
        if valuea == valueb && keya != keyb
          doubles.push(valuea)
        end
      end
    end
    doubles.uniq
  end

  def scan_claiming_pair_line(grid_line, grid_col)
    col_off = (grid_col-1)*3
    line_off = (grid_line-1)*3
    all = (1..9).to_a
    (1..3).to_a.each do |line|
      remaining = all - candidates_outside_grid_line(line_off+line, (1..9).to_a - (col_off+1..col_off+3).to_a)
      # puts "candidates ... (#{line_off+line},#{(1..9).to_a - (col_off..col_off+3).to_a})"
      # puts "#{candidates_outside_grid_line(line_off+line, (1..9).to_a - (col_off..col_off+3).to_a)}"
      # puts "#{remaining}(line)"
      if remaining.size > 0
        iterator((1..3)){ |lines,cols|
          next if lines == line
          # puts "@field[#{line_off+lines}][#{col_off+cols}] = #{@field[line_off+lines][col_off+cols]} - #{remaining}"
          @field[line_off+lines][col_off+cols] -= remaining
          # puts "--> #{@field[line_off+lines][col_off+cols]}"
        }

      end
    end
  end

  def scan_claiming_pair_col(grid_line, grid_col)
    col_off = (grid_col-1)*3
    line_off = (grid_line-1)*3
    all = (1..9).to_a
    (1..3).to_a.each do |col|
      remaining = all - candidates_outside_grid_col(col_off+col, (1..9).to_a - (line_off+1..line_off+3).to_a)
      # puts "#{remaining}(col)"
      if remaining.size > 1
        iterator((1..3)){ |lines,cols|
          next if cols == col
          # puts "@field[#{line_off+lines}][#{col_off+cols}] = #{@field[line_off+lines][col_off+cols]} - #{remaining}"
          @field[line_off+lines][col_off+cols] -= remaining
          # puts "--> #{@field[line_off+lines][col_off+cols]}"
        }
      end
    end
  end

  def candidates_outside_grid_line(line, indexes)
    candidates = []
    indexes.each do |col|
      # puts "get[#{line}][#{col}]= #{@field[line][col]}"
      candidates +=@field[line][col]
    end
    # puts "--> outside: #{candidates.uniq}"
    candidates.uniq
  end

  def candidates_outside_grid_col(col, indexes)
    candidates = []
    indexes.each do |line|
      #puts "get[#{line}][#{col}]= #{@field[line][col]}"
      candidates +=@field[line][col]
    end
    #puts "--> outside: #{candidates.uniq}"
    candidates.uniq
  end

  def advanced_scan_grid(grid_col, grid_line)
    col_off = (grid_col-1)*3
    line_off = (grid_line-1)*3

    ((1..3).to_a-[grid_col]).each do |col|
      uniq_col = uniq_in_col(col, grid_line)
      iterator((1..3)){ |cols,lines|
        @field[col_off+cols][line_off+lines] -= uniq_col[lines] if @field[col_off+cols][line_off+lines].size > 1
      }
    end

    ((1..3).to_a-[grid_line]).each do |line|
      uniq_line = uniq_in_line(grid_col, line)
      iterator((1..3)){ |lines, cols|
        @field[col_off+cols][line_off+lines] -= uniq_line[cols] if @field[col_off+cols][line_off+lines].size > 1
      }
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
    statistics = statistics_grid(col,line)
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

  def statistics_grid(col,line)
    col_off = (col-1)*3
    line_off = (line-1)*3
    statistics = {}
    iterator((1..3)){|col,line|
      @field[col_off+col][line_off+line].each do |item|
        statistics[item] = (statistics[item]||0) + 1
      end
    }
    statistics
  end

  def statistics_line(line)
    statistics = {}
    (1..9).to_a.each do |col|
      @field[line][col].each do |item|
        statistics[item] = (statistics[item]||0) + 1
      end
    end
    statistics
  end

  def statistics_col(col)
    statistics = {}
    (1..9).to_a.each do |line|
      @field[line][col].each do |item|
        statistics[item] = (statistics[item]||0) + 1
      end
    end
    statistics
  end

  def solutions_grid(col,line)
    col_off = (col-1)*3
    line_off = (line-1)*3
    solutions = []
    iterator((1..3)){|col,line|
      solutions.push(@field[col_off+col][line_off+line]) if @field[col_off+col][line_off+line].size == 1
    }
    solutions.flatten
  end

  def entropy
    sum = 0
    iterator((1..9)) { |col, line|
      sum += @field[col][line].size
    }
    sum
  end

  def iterator(range)
    range.to_a.each do |col|
      range.to_a.each do |line|
        yield(col, line)
      end
    end
  end

  def to_field
    SudokuField.new.solved(@field)
  end

  def to_field_transpose
    SudokuField.new.solved_transpose(@field)
  end
end
