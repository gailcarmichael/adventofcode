input = File.read("day01-input.txt").strip

halfway = input.length/2

sum = 0
sum2 = 0

input.each_char.each_with_index do |currDigit, index|

  nextDigit = input[(index + 1) % input.length]
  nextDigit2 = input[(index + halfway) % input.length]

  sum += currDigit.to_i if currDigit == nextDigit
  sum2 += currDigit.to_i if currDigit == nextDigit2
end

puts "Sum of consecutively repeated digits is %d" % sum
puts "Sum of halfway-round repeated digits is %d" % sum2
