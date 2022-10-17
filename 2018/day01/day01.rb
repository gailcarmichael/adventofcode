class FrequencyDriftChecker
  def initialize(change_list)
    @change_list = change_list
  end

  def sum_freq_changes
    @change_list.reduce(:+)
  end

  def look_for_duplicate_freq
    look_for_duplicate_freq_helper(Array.new << 0)
  end

  private def look_for_duplicate_freq_helper(freq_list)
    @change_list.each do |change_value|
      last = freq_list.last || 0
      next_value = last + change_value
      if freq_list.include? next_value
        return next_value
      else
        freq_list << next_value
      end
    end
    look_for_duplicate_freq_helper(freq_list)
  end

end

# Test input
File.read("day01-input-test-part1.txt").strip.split("\n").each do |line|
  checker = FrequencyDriftChecker.new(line.split(", ").map { |num_str| num_str.to_i })
  puts "Part 1 test result: #{checker.sum_freq_changes}"
end

puts

File.read("day01-input-test-part2.txt").strip.split("\n").each do |line|
  checker = FrequencyDriftChecker.new(line.split(", ").map { |num_str| num_str.to_i })
  puts "Part 2 test result: #{checker.look_for_duplicate_freq}"
end

puts

# Real input
list = File.read("day01-input.txt").strip.split("\n").map { |num_str| num_str.to_i }
checker = FrequencyDriftChecker.new(list)
puts "Real result part 1: #{checker.sum_freq_changes}"
1puts "Real result part 2: #{checker.look_for_duplicate_freq}"
