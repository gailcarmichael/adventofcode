class BingoGame

  def initialize(numbers)
    @boards = []
    @numbers_to_call = numbers
  end

  def add_board(board)
    @boards.push(SingleBoard.new(board))
  end

  def get_board(board_num=0)
    nil if @boards.size == 0
    @boards[board_num]
  end

  def play_and_get_score_for_winner
    @numbers_to_call.each do |number_to_call|
      @boards.each do |board|
        board.call_number(number_to_call)
        if board.winner?
          return board.sum_uncalled_numbers * number_to_call
        end
      end
    end
  end

  def play_and_get_score_for_last_winner
    winning_board_indexes = []
    last_winning_number_called = -1
    
    @numbers_to_call.each do |number_to_call|
      @boards.each_with_index do |board, index|
        next if winning_board_indexes.include?(index)
        board.call_number(number_to_call)
        if board.winner?
          winning_board_indexes.push(index)
          last_winning_number_called = number_to_call
        end
      end
    end

    @boards[winning_board_indexes.last].sum_uncalled_numbers * last_winning_number_called
  end

end

class SingleBoard

  attr_reader :sum_uncalled_numbers

  def initialize(board_grid)
    @board_grid = board_grid
    @called_numbers = Array.new(5){Array.new(5)}
    @sum_uncalled_numbers = @board_grid.inject(0){|sum, row| sum + row.inject(:+)}
  end

  def call_number(number)
    @board_grid.each_with_index do |row, row_num|
      col_num = row.find_index(number)
      if col_num != nil
        @called_numbers[row_num][col_num] = true 
        @sum_uncalled_numbers -= @board_grid[row_num][col_num]
      end
    end
  end

  def winner?()
    @called_numbers.any? {|row| row.all?} or
      @called_numbers.transpose.any? {|col| col.all?}
  end

end


################################################################

def process_file(filename)
  lines = File.readlines(filename, chomp: true)
  num_boards = (lines.size - 1) / 6

  game = BingoGame.new(lines.shift.split(",").map(&:to_i))

  (0...num_boards).each do |board_num|
    lines.shift # preceding blank line
    game.add_board((0...5).map {|board_line_num| lines.shift.split.map(&:to_i)})
  end

  game

end

################################################################

test_game = process_file("day04-input-test.txt")
puts "Test score of winning board: #{test_game.play_and_get_score_for_winner}"

game = process_file("day04-input.txt")
puts "Real score of winning board: #{game.play_and_get_score_for_winner}"

test_game = process_file("day04-input-test.txt")
puts "Test score of LAST winning board: #{test_game.play_and_get_score_for_last_winner}"

game = process_file("day04-input.txt")
puts "Real score of LAST winning board: #{game.play_and_get_score_for_last_winner}"