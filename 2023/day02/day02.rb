def game_possible?(game_info, max_red, max_green, max_blue)
  !game_info[:grabs].any? do |grab|
    grab["red"] > max_red || grab["green"] > max_green || grab["blue"] > max_blue
  end
end

def sum_possible_game_ids(game_info_list, max_red, max_green, max_blue)
  game_info_list.filter{|i| game_possible?(i, max_red, max_green, max_blue)}.sum{|g| g[:id]}
end

####

def power_of_min_set(game_info)
  min_red = min_green = min_blue = 0
  game_info[:grabs].each do |grab|
    min_red = [min_red, grab["red"]].max
    min_green = [min_green, grab["green"]].max
    min_blue = [min_blue, grab["blue"]].max
  end
  min_red * min_green * min_blue
end

def sum_of_power_of_min_cube_sets(game_info_list)
  game_info_list.map{|g| power_of_min_set(g)}.sum
end

####

def process_file(filename)
  File.read(filename).strip.split("\n").map do |line|
    game_id_string, game_info_string = line.split(": ")
    game_id = game_id_string.split(" ")[1].to_i

    grabs = game_info_string.split("; ").map do |one_grab_string|
      this_grab = Hash.new(0)
      one_grab_string.split(", ").each do |num_and_colour|
        num, colour = num_and_colour.split(" ")
        this_grab[colour] = num.to_i
      end
      this_grab
    end

    {id: game_id, grabs: grabs}
  end
end

puts "Sum of games that would be possible (test): #{sum_possible_game_ids(process_file("day02-input-test.txt"), 12, 13, 14)}"
puts "Sum of games that would be possible (real): #{sum_possible_game_ids(process_file("day02-input.txt"), 12, 13, 14)}"

puts "Sum of power of min-cube sets (test): #{sum_of_power_of_min_cube_sets(process_file("day02-input-test.txt"))}"
puts "Sum of power of min-cube sets (real): #{sum_of_power_of_min_cube_sets(process_file("day02-input.txt"))}"
