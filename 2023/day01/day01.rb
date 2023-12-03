DIGIT_WORDS = {"one" => "1", "two" => "2", "three" => "3",
                 "four" => "4", "five" => "5", "six" => "6",
                 "seven" => "7", "eight" => "8", "nine" => "9"}

def calibration_part_1(lines)
  lines.map do |line|
    digits = line.split("").filter {|char| char.match?(/[[:digit:]]/)}
    (digits[0] + digits[-1]).to_i
  end.inject(:+)
end


def calibration_part_2(lines)
  # Find first digit word and replace it with a digit
  expression = Regexp.new(DIGIT_WORDS.keys.join("|"))
  new_lines = lines.map do |line|
    matches = line.scan(/(#{expression})/)

    if matches && matches.length > 0
      # Only sub if there isn't a real digit that comes first
      if (!line.split(matches[0][0])[0].split("").any?{|char| char.match?(/[[:digit:]]/)})
        line.sub!(matches[0][0], DIGIT_WORDS[matches[0][0]])
      end
    end

    line
  end

  # Find second digit word and replace it with a digit
  reverse_expression = Regexp.new(DIGIT_WORDS.keys.map{|dw| dw.reverse}.join("|"))

  new_lines = new_lines.map do |line|
    reversed_line = line.reverse
    matches = reversed_line.scan(/(#{reverse_expression})/)

    if matches && matches.length > 0
      reversed_line.sub!(matches[0][0], DIGIT_WORDS[matches[0][0].reverse])
    end

    reversed_line.reverse
  end

  # Use part 1 to get the final sum needed
  calibration_part_1(new_lines)
end


def process_file(filename)
  File.read(filename).strip.split("\n")
end

p
puts "Sum of calibration values (test): #{calibration_part_1(process_file("day01-input-test.txt"))}"
puts "Sum of calibration values (real): #{calibration_part_1(process_file("day01-input.txt"))}"

p
puts "Sum of calibration values part 2 (test): #{calibration_part_2(process_file("day01-input-test2.txt"))}"
puts "Sum of calibration values part 2 (real): #{calibration_part_2(process_file("day01-input.txt"))}"

p
# puts "Answer for 4rnhhlq86dl87peightwogv is #{calibration_part_2(["4rnhhlq86dl87peightwogv"])}"
