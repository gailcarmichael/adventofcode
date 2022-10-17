def count_num_increases(depths)
  increase_count = 0
  depths.each_cons(2) {|d1, d2| increase_count += 1 if d2 > d1 }
  increase_count
end


def count_sliding_window_increases(depths)
  increase_count = 0
  prev_sum = 999999
  depths.each_cons(3) do |d1, d2, d3|
    increase_count += 1 if prev_sum < (d1+d2+d3)
    prev_sum = (d1+d2+d3)
  end
  increase_count
end


depths_test = File.read("day01-input-test.txt").strip.split("\n").collect(&:to_i)
depths = File.read("day01-input.txt").strip.split("\n").collect(&:to_i)

puts "Part 1 test input: #{count_num_increases(depths_test)}"
puts "Part 1 real input: #{count_num_increases(depths)}"

puts "Part 2 test input: #{count_sliding_window_increases(depths_test)}"
puts "Part 2 real input: #{count_sliding_window_increases(depths)}"