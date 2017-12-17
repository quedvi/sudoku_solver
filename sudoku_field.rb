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
    @field[0] = [ 8, 0, 0, 0, 1, 3, 0, 0, 6 ]
    @field[1] = [ 0, 0, 0, 0, 0, 0, 3, 4, 0 ]
    @field[2] = [ 0, 6, 9, 5, 0, 0, 0, 0, 0 ]
    @field[3] = [ 7, 0, 0, 0, 3, 2, 0, 1, 0 ]
    @field[4] = [ 0, 0, 0, 0, 0, 0, 0, 0, 0 ]
    @field[5] = [ 0, 2, 0, 8, 7, 0, 0, 0, 3 ]
    @field[6] = [ 0, 0, 0, 0, 0, 1, 6, 8, 0 ]
    @field[7] = [ 0, 3, 7, 0, 0, 0, 0, 0, 0 ]
    @field[8] = [ 5, 0, 0, 7, 6, 0, 0, 0, 2 ]

    # @field[0] = [ 0, 3, 0, 0, 1, 0, 0, 7, 0 ]
    # @field[1] = [ 0, 0, 0, 6, 0, 3, 1, 0, 2 ]
    # @field[2] = [ 6, 0, 0, 0, 0, 0, 0, 0, 0 ]
    # @field[3] = [ 0, 2, 4, 0, 0, 7, 0, 0, 3 ]
    # @field[4] = [ 0, 0, 0, 0, 6, 0, 0, 0, 0 ]
    # @field[5] = [ 1, 0, 0, 5, 0, 0, 8, 4, 0 ]
    # @field[6] = [ 0, 0, 0, 0, 0, 0, 0, 0, 5 ]
    # @field[7] = [ 2, 0, 1, 3, 0, 4, 0, 0, 0 ]
    # @field[8] = [ 0, 4, 0, 0, 9, 0, 0, 8, 0 ]
    true
  end

end
