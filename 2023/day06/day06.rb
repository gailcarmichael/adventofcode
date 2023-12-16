
# (max_time - time_holding_button) * time_holding_button > record
# (time_holding_button * max_time) - (time_holding_button * time_holding_button) > record
# -(time_holding_button * time_holding_button) + (time_holding_button * max_time) - record > 0
# (time_holding_button * time_holding_button) - (time_holding_button * max_time) + record < 0

# Quadratic formula for a*x^2 + bx + c = 0 is (-b±√(b²-4ac))/(2a)
# So for our values, it will be  (max_time ± √(max_time²-4*record)) / (2)

def get_range_of_button_presses(max_time, record_distance)
  sqrt = Math.sqrt(max_time*max_time - (4*record_distance))
  [((max_time - sqrt)/2).floor + 1, ((max_time + sqrt)/2).ceil - 1]
end

def product_of_ways_to_beat_record(race_list)
  race_list.map do |race|
    race_range = get_range_of_button_presses(race[0], race[1])
    race_range[1] - race_range[0] + 1
  end.inject(:*)
end

####

def process_file(filename, ignore_spaces=false)
  races = Array.new
  lines = File.read(filename).strip.split("\n").map(&:split)

  if ignore_spaces
    races.push(
      [lines[0][1..].inject("") {|so_far, num| so_far + num}.to_i,
       lines[1][1..].inject("") {|so_far, num| so_far + num}.to_i])
  else
    1.upto(lines[0].size-1) do |index|
      races.push([lines[0][index].to_i, lines[1][index].to_i])
    end
  end
  races
end

####

puts "Product of ways to beat the record (test): #{product_of_ways_to_beat_record(process_file("day06-input-test.txt"))}"
puts "Product of ways to beat the record (real): #{product_of_ways_to_beat_record(process_file("day06-input.txt"))}"


puts "Product of ways to beat the record part 2 (test): #{product_of_ways_to_beat_record(process_file("day06-input-test.txt", true))}"
puts "Product of ways to beat the record part 2 (real): #{product_of_ways_to_beat_record(process_file("day06-input.txt", true))}"
