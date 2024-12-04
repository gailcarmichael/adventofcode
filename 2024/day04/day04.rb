##########
# Part 1

UP =   [[-1, 0], [-2, 0], [-3, 0]]
DOWN = [[1, 0],  [2, 0],  [3, 0]]

LEFT =  [[0, -1], [0, -2], [0, -3]]
RIGHT = [[0, 1],  [0, 2],  [0, 3]]

DIAG_UP_L = [[-1,-1], [-2,-2], [-3,-3]]
DIAG_UP_R = [[-1,1],  [-2,2],  [-3,3]]

DIAG_DOWN_L = [[1,-1], [2,-2], [3,-3]]
DIAG_DOWN_R = [[1,1],  [2,2],  [3,3]]

ALL_DIRS = [UP, DOWN, LEFT, RIGHT, DIAG_UP_L, DIAG_UP_R, DIAG_DOWN_L, DIAG_DOWN_R]

def count_xmas(wordsearch)
  total = 0
  wordsearch.each_pair do |coord, letter|
    if letter == "X"
      total += ALL_DIRS.count {|dir_array| xmas_present?(wordsearch, coord, dir_array)}
    end
  end
  total
end

def xmas_present?(wordsearch, start, dir_array)
  wordsearch[[start[0] + dir_array[0][0], start[1] + dir_array[0][1]]] == "M" &&
    wordsearch[[start[0] + dir_array[1][0], start[1] + dir_array[1][1]]] == "A" &&
    wordsearch[[start[0] + dir_array[2][0], start[1] + dir_array[2][1]]] == "S"
end

##########
# Part 2

def count_xmas_cross(wordsearch)
  total = 0
  wordsearch.each_pair do |coord, letter|
    if letter == "A" && (xmas_cross_dr_present?(wordsearch, coord) &&
                         xmas_cross_dl_present?(wordsearch, coord))
      total += 1
    end
  end
  total
end

def xmas_cross_dr_present?(wordsearch, start)
  (wordsearch[[start[0] - 1, start[1] - 1]] == "M" &&
    wordsearch[[start[0] + 1, start[1] + 1]] == "S") ||

  (wordsearch[[start[0] - 1, start[1] - 1]] == "S" &&
    wordsearch[[start[0] + 1, start[1] + 1]] == "M")
end

def xmas_cross_dl_present?(wordsearch, start)
  (wordsearch[[start[0] - 1, start[1] + 1]] == "M" &&
    wordsearch[[start[0] + 1, start[1] - 1]] == "S") ||

  (wordsearch[[start[0] - 1, start[1] + 1]] == "S" &&
    wordsearch[[start[0] + 1, start[1] - 1]] == "M")
end

##########

def process_file(filename)
  wordsearch = Hash.new
  File.read(filename).strip.split("\n").each_with_index do |line, row|
    line.split("").each_with_index do |letter, col|
      wordsearch[[row,col]] = letter
    end
  end
  wordsearch
end

puts
wordsearch = process_file("day04-input-test.txt")
puts "Total times XMAS appears (test): #{count_xmas(wordsearch)}"
puts "Total times XMAS cross appears (test): #{count_xmas_cross(wordsearch)}"

puts
wordsearch = process_file("day04-input.txt")
puts "Total times XMAS appears (real): #{count_xmas(wordsearch)}"
puts "Total times XMAS appears (real): #{count_xmas_cross(wordsearch)}"
