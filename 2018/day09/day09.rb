class MarbleGame
  def initialize(num_players, last_marble_score)
    @num_players = num_players
    @given_last_marble_score = last_marble_score
  end

  def play
    current_marble_num = 0

    circle = [0]
    current_marble_index = 0

    player_scores = Hash.new(0)
    current_player = -1

    loop do
      current_player = (current_player + 1) % @num_players
      current_marble_num += 1

      if (current_marble_num % 23 == 0)
      
        player_scores[current_player] += current_marble_num
        
        delete_index = (current_marble_index - 7)
        delete_index = circle.length + delete_index if delete_index < 0
        
        player_scores[current_player] += circle.delete_at(delete_index)
        current_marble_index = delete_index

      else # regular round

        current_marble_index = (current_marble_index + 2) % circle.length
        circle.insert(current_marble_index, current_marble_num)
      
      end

      break if current_marble_num == @given_last_marble_score
    end

    puts "High score: #{player_scores.values.max}"
  end

  def circle_to_s(circle, current_marble_index, current_player)
    result = "[#{current_player+1}] "
    circle.each_with_index do |marble_num, index|
      if current_marble_index == index
        result += " (#{marble_num})"
      else
        result += " #{marble_num}"
      end
    end
    result
  end
end

###

def process_file(filename, message, arg=1)
  File.read(filename).strip.split("\n").each do |line|
    m = /(.+) players; last marble is worth (.+) points/.match(line)
    MarbleGame.new(m[1].to_i, m[2].to_i*arg).play
  end
end

puts "Test part 1: "
process_file("day09-input-test.txt", :play_marble_game)

puts "Real part 1: "
process_file("day09-input.txt", :play_marble_game)

puts "Real part 2: "
process_file("day09-input.txt", :play_marble_game, 100)
