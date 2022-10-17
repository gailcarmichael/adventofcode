class Polymer
  def initialize(polymer_array)
    @polymer_array = polymer_array
  end

  def length
    @polymer_array.length
  end

  def react_result
    stack = []
    @polymer_array.each do |unit|
      if stack.last && stack.last != unit && stack.last.downcase == unit.downcase
        stack.pop
      else
        stack.push unit
      end
    end
    Polymer.new(stack)
  end

  def react_result_length
    react_result.length
  end

  def remove_best_unit_length
    min_length = 999999
    ('a'..'z').each do |candidate_unit|
      candidate_polymer = Polymer.new(@polymer_array.reject {|unit| unit.downcase == candidate_unit})
      min_length = [candidate_polymer.react_result_length, min_length].min
    end
    min_length
  end

  def to_s
    polymer_array.to_s
  end
end

###

def process_file(filename, message)
  polymer = Polymer.new(File.read(filename).strip.split(""))
  polymer.public_send(message)
end

puts "Test part 1: #{process_file("day05-input-test.txt", :react_result_length)}"
puts "Real part 1: #{process_file("day05-input.txt", :react_result_length)}"

puts "Test part 2: #{process_file("day05-input-test.txt", :remove_best_unit_length)}"
puts "Real part 2: #{process_file("day05-input.txt", :remove_best_unit_length)}"
