require 'set'

def index_of_first_unique_window(datastream, window_size)
    datastream.split("").each_with_index do |char, index|
        window = datastream.slice(index, window_size).split("")
        if (Set.new(window).size == window_size)
            return index + window_size
        end
    end
    return -1
end

input_test = [
    "mjqjpqmgbljsphdztnvjfqwrcgsmlb",
    "bvwbjplbgvbhsrlpgdmjqwftvncz",
    "nppdvjthqldpwncqszvftbrmjlhg",
    "nznrnfrfntjfmvfwmzdfjlvtqnbhcprsg",
    "zcfzfwzzqfrljwzlrfnpqdbhtmscgvjw"
]

input_test.each_with_index do |datastream, index|
    puts "Test #{index} (window size 4): #{index_of_first_unique_window(datastream, 4)}"
end

input_test.each_with_index do |datastream, index|
    puts "Test #{index} (window size 14): #{index_of_first_unique_window(datastream, 14)}"
end

input_real = File.read("day06-input.txt").strip
puts "Real: #{index_of_first_unique_window(input_real, 4)}"
puts "Real: #{index_of_first_unique_window(input_real, 14)}"