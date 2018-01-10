input = File.read("day01-input.txt").strip

repeats = []
repeats2 = []

halfway = input.length/2

input.each_char.each_with_index do |currDigit, index|

  nextDigit = input[(index + 1) % input.length]
  nextDigit2 = input[(index + halfway) % input.length]

  repeats.push(currDigit) if currDigit == nextDigit
  repeats2.push(currDigit) if currDigit == nextDigit2
end

sum = repeats.inject(0) { |sum, digit| sum + digit.to_i }
sum2 = repeats2.inject(0) { |sum, digit| sum + digit.to_i }

puts "Sum of consecutively repeated digits is %d" % sum
puts "Sum of halfway-round repeated digits is %d" % sum2
