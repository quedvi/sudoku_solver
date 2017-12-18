require("./sudoku.rb")
require("./sudoku_field.rb")

init = SudokuField.new(:hard)
sudoku = Sudoku.new(init)

step = 0

until sudoku.to_field.solved?
  sudoku.reduce_solved
  sudoku.find_single_hidden
  sudoku.reduce_solved
  sudoku.find_pair
  sudoku.reduce_solved

  sudoku.reduce_line_grid
  sudoku.reduce_col_grid
  sudoku.reduce_advance_scan
  step +=1
  break if step % 50 == 0
end


easy:
{_3_}{_4_}{_7_}   {_9_}{_2_}{_6_}   {_8_}{_1_}{_5_}
{_9_}{_8_}{_1_}   {_4_}{_7_}{_5_}   {_6_}{_2_}{_3_}
{_2_}{_5_}{_6_}   {_1_}{_8_}{_3_}   {_7_}{_4_}{_9_}

{_8_}{_6_}{_2_}   {_3_}{_5_}{_1_}   {_9_}{_7_}{_4_}
{_4_}{_1_}{_9_}   {_7_}{_6_}{_2_}   {_5_}{_3_}{_8_}
{_7_}{_3_}{_5_}   {_8_}{_9_}{_4_}   {_1_}{_6_}{_2_}

{_1_}{_7_}{_3_}   {_5_}{_4_}{_8_}   {_2_}{_9_}{_6_}
{_5_}{_2_}{_4_}   {_6_}{_1_}{_9_}   {_3_}{_8_}{_7_}
{_6_}{_9_}{_8_}   {_2_}{_3_}{_7_}   {_4_}{_5_}{_1_}


hard:
{_4_}{_3_}{_2_}   {_5_}{_8_}{_6_}   {_7_}{_9_}{_1_}
{_5_}{_6_}{_9_}   {_7_}{_1_}{_3_}   {_4_}{_8_}{_2_}
{_1_}{_7_}{_8_}   {_9_}{_4_}{_2_}   {_5_}{_3_}{_6_}

{_6_}{_1_}{_5_}   {_8_}{_9_}{_4_}   {_2_}{_7_}{_3_}
{_2_}{_9_}{_4_}   {_3_}{_7_}{_1_}   {_8_}{_6_}{_5_}
{_7_}{_8_}{_3_}   {_2_}{_6_}{_5_}   {_1_}{_4_}{_9_}

{_9_}{_2_}{_7_}   {_1_}{_3_}{_8_}   {_6_}{_5_}{_4_}
{_8_}{_4_}{_1_}   {_6_}{_5_}{_9_}   {_3_}{_2_}{_7_}
{_3_}{_5_}{_6_}   {_4_}{_2_}{_7_}   {_9_}{_1_}{_8_}

----------------------------------------------------

{_5_}{_2_}{_6_}   {_7_}{_1_}{_3_}   {_9_}{_4_}{_8_}
{_7_}{_1_}{_4_}   {_6_}{_8_}{_9_}   {_2_}{_5_}{_3_}
{_8_}{_3_}{_9_}   {_4_}{_5_}{_2_}   {_1_}{_6_}{_7_}

{_1_}{_6_}{_5_}   {_2_}{_9_}{_8_}   {_3_}{_7_}{_4_}
{_3_}{_7_}{_8_}   {_1_}{_6_}{_4_}   {_5_}{_9_}{_2_}
{_9_}{_4_}{_2_}   {_5_}{_3_}{_7_}   {_8_}{_1_}{_6_}

{_2_}{_5_}{_1_}   {_3_}{_4_}{_6_}   {_7_}{_8_}{_9_}
{_6_}{_9_}{_7_}   {_8_}{_2_}{_5_}   {_4_}{_3_}{_1_}
{_4_}{_8_}{_3_}   {_9_}{_7_}{_1_}   {_6_}{_2_}{_5_}


evil:
{_8_}{?3?}{?3?}  {?2?}{_1_}{_3_}  {?4?}{?4?}{_6_}
{?2?}{?3?}{?3?}  {?3?}{?3?}{?4?}  {_3_}{_4_}{?3?}
{_3_}{_6_}{_9_}  {_5_}{?3?}{?3?}  {?4?}{?2?}{?2?}

{_7_}{?4?}{?4?}  {?3?}{_3_}{_2_}  {?4?}{_1_}{?4?}
{?2?}{?4?}{_3_}  {_1_}{?2?}{?4?}  {?6?}{?5?}{?4?}
{?3?}{_2_}{?4?}  {_8_}{_7_}{?4?}  {?3?}{?3?}{_3_}

{?3?}{?2?}{?2?}  {_3_}{_5_}{_1_}  {_6_}{_8_}{_7_}
{_6_}{_3_}{_7_}  {?3?}{?4?}{?3?}  {?4?}{?2?}{?4?}
{_5_}{?4?}{?3?}  {_7_}{_6_}{?2?}  {?2?}{_3_}{_2_}

------------------------------------------------------

{_8_}{?3?}{?3?}  {?2?}{_1_}{_3_}  {?4?}{?4?}{_6_}
{?2?}{?3?}{?3?}  {?3?}{?3?}{?4?}  {_3_}{_4_}{?3?}
{_3_}{_6_}{_9_}  {_5_}{?3?}{?3?}  {?4?}{?2?}{?2?}

{_7_}{?4?}{?4?}  {?3?}{_3_}{_2_}  {?4?}{_1_}{?4?}
{?2?}{?4?}{_3_}  {_1_}{?2?}{?4?}  {?6?}{?5?}{?4?}
{?3?}{_2_}{?4?}  {_8_}{_7_}{?4?}  {?3?}{?3?}{_3_}

{?3?}{?2?}{?2?}  {_3_}{_5_}{_1_}  {_6_}{_8_}{_7_}
{_6_}{_3_}{_7_}  {?3?}{?4?}{?3?}  {?4?}{?2?}{?4?}
{_5_}{?4?}{?3?}  {_7_}{_6_}{?2?}  {?2?}{_3_}{_2_}

------------------------------------------------------
{?4?}{_3_}{?4?}   {?3?}{_1_}{?4?}   {?3?}{_7_}{?4?}
{?5?}{?4?}{?4?}   {_6_}{?3?}{_3_}   {_1_}{?2?}{_2_}
{_6_}{_1_}{?5?}   {?4?}{?4?}{?4?}   {?3?}{?3?}{?3?}

{?2?}{_2_}{_4_}   {?2?}{_8_}{_7_}   {?3?}{?4?}{_3_}
{?5?}{?4?}{?5?}   {_4_}{_6_}{?3?}   {?4?}{?4?}{?3?}
{_1_}{?3?}{?3?}   {_5_}{_3_}{?2?}   {_8_}{_4_}{?3?}

{?4?}{?4?}{?5?}   {?4?}{?2?}{?4?}   {_4_}{?5?}{_5_}
{_2_}{?5?}{_1_}   {_3_}{?2?}{_4_}   {?3?}{?2?}{?3?}
{?3?}{_4_}{?4?}   {?3?}{_9_}{?4?}   {?4?}{_8_}{?3?}
