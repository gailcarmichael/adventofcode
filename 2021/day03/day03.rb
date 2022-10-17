require 'matrix'

################################################################

def most_common_bits(matrix)
  (0...matrix.column_size).map do |col|
    if matrix.column(col).reduce(&:+) < matrix.row_size / 2.to_f
      0
    else
      1
    end
  end
end

def least_common_bits(matrix)
  most_common = most_common_bits(matrix)
  most_common.map{|bit| bit ^ 1}

end

def power_consumption(matrix)
  gamma = most_common_bits(matrix).join().to_i(2)
  epsilon = least_common_bits(matrix).join().to_i(2)
  gamma * epsilon
end

################################################################

def get_rating(matrix, common_bit_method, curr_bit_index = 0)
  common_bit_result = common_bit_method.call(matrix)
  new_rows = matrix.to_a.filter{|row| row[curr_bit_index] == common_bit_result[curr_bit_index]}

  if new_rows.size == 1
    new_rows[0]
  elsif curr_bit_index >= matrix.column_size
    puts "get_rating: #{curr_bit_index} is invalid!"
  else
    get_rating(Matrix.rows(new_rows), common_bit_method, curr_bit_index + 1)
  end
end

def get_life_support_rating(matrix)
  o2_gen_rating = get_rating(matrix, method(:most_common_bits))
  scrubber_rating = get_rating(matrix, method(:least_common_bits))
  o2_gen_rating.join('').to_i(2) * scrubber_rating.join('').to_i(2)
end

################################################################

def process_file(filename)
  rows = []
  File.read(filename).strip.split("\n").each do |line|
    rows.push(line.split("").map(&:to_i))
  end
  Matrix.rows(rows)
end

################################################################

matrix = process_file("day03-input-test.txt")
puts "Test power consumption: #{power_consumption(matrix)}"
puts "Test life support rating: #{get_life_support_rating(matrix)}"


matrix = process_file("day03-input.txt")
puts "Real power consumption: #{power_consumption(matrix)}"
puts "Real life support rating: #{get_life_support_rating(matrix)}"