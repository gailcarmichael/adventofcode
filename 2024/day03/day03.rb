def sum_of_multiplies(program)
  match_data = program.scan(/mul\((\d{1,3}),(\d{1,3})\)/)
  match_data.map do |pair|
    pair[0].to_i * pair[1].to_i
  end.sum
end

def sum_of_multiplies_with_conditionals(program)
  match_data = program.scan(/(mul\((\d{1,3}),(\d{1,3})\)|don't\(\)|do\(\))/)
  total = 0
  enabled = true
  match_data.each do |data|
    if (data[0] == "do()")
      enabled = true
    elsif (data[0] == "don't()")
      enabled = false
    elsif enabled
      total += data[1].to_i * data[2].to_i
    end
  end
  total
end

def process_file(filename)
  File.read(filename).strip.split("\n").join('')
end

puts
test_file = process_file("day03-input-test.txt")
test_file_2 = process_file("day03-input-test2.txt")
puts "Sum of multiplies (test): #{sum_of_multiplies(test_file)}"
puts "Sum of multiplies with conditionals (test): #{sum_of_multiplies_with_conditionals(test_file)}"
puts "Sum of multiplies with conditionals 2 (test): #{sum_of_multiplies_with_conditionals(test_file_2)}"

puts
real_file = process_file("day03-input.txt")
puts "Sum of multiplies (real): #{sum_of_multiplies(real_file)}"
puts "Sum of multiplies with conditionals (real): #{sum_of_multiplies_with_conditionals(real_file)}"
