def get_median(pos_list)
  # https://stackoverflow.com/questions/14859120/calculating-median-in-ruby
  sorted_pos_list = pos_list.sort
  len = pos_list.length
  (sorted_pos_list[(len-1)/2] + sorted_pos_list[len/2]) / 2.0
end

def get_fuel_cost_constant(pos_list, final_pos)
  pos_list.map{|pos| (pos-final_pos).abs}.reduce(&:+)
end

def get_fuel_cost_partial_sum(pos_list)
  # Turns out this is just lucky! It may not be the case that the final
  # position is within the range of the number of crabs. Using min/max
  # of the crab positions would work better.
  (0..pos_list.length).map{|pos| get_fuel_cost_partial_sum_for_pos(pos_list, pos)}.min
end

def get_fuel_cost_partial_sum_for_pos(pos_list, final_pos)
  pos_list.map do |pos| 
    n = (pos-final_pos).abs
    (n*(n+1))/2.0
  end.reduce(&:+)
end

################################################################

def process_file(filename)
  File.read(filename, chomp: true).split(",").map(&:to_i)
end

################################################################

puts "Test:"
positions = process_file("day07-input-test.txt")
puts "Median: #{get_median(positions)}"
puts "Fuel cost (constant): #{get_fuel_cost_constant(positions, get_median(positions))}"
puts "Fuel cost (partial sum): #{get_fuel_cost_partial_sum(positions)}"

puts "\nReal:"
positions = process_file("day07-input.txt")
puts "Median: #{get_median(positions)}"
puts "Fuel cost: #{get_fuel_cost_constant(positions, get_median(positions))}"
puts "Fuel cost (partial sum): #{get_fuel_cost_partial_sum(positions)}"
