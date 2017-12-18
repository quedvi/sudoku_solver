# test program to show how to use the sudoku_solver

require("./sudoku.rb")
require("./sudoku_field.rb")

init = SudokuField.new(:unsolved)
sudoku = Sudoku.new(init)
sudoku.solve
