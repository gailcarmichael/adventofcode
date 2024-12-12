def apply_rule(value)
  new_values = Array.new

  value_string = value.to_s

  # Rule 1: 0 replaced with 1
  if value == 0
    new_values.push(1)

  # Rule 2: Even number stones split into two
  elsif value_string.length.even?
    new_values.push(value_string[0..(value_string.length-1)/2].to_i)
    new_values.push(value_string[(value_string.length)/2..-1].to_i)

  # Rule 3: Multiply value by 2024
  else
    new_values.push(value*2024)
  end

  new_values
end

###########################

def do_blinks(initial_values, num_blinks)
  results_as_string = ""
  results_as_string += "#{initial_values.length} stones:\t[" + initial_values.join(",") + "]"

  prev_values = initial_values
  1.upto(num_blinks) do |blink_num|
    new_values = Array.new
    prev_values.each do |value|
      new_values += apply_rule(value)
    end
    results_as_string += "\n#{new_values.length} stones (#{new_values.length - prev_values.length} more):\t[" + new_values.join(",") + "]"

    prev_values = new_values
  end

  file = File.new("output.txt", 'w')
  file.puts results_as_string
  file.close

  prev_values
end

###########################

# This one returns a size, not the list itself
def do_blinks_tree_search(initial_values, num_blinks, curr_blink=0, memo=Hash.new)
  total_new_size = initial_values.map do |value|
    new_size = 0
    if (memo.has_key?([value, curr_blink])) # we saw this value with a certain number of blinks
      new_size = memo[[value, curr_blink]]
    elsif (curr_blink == num_blinks-1) # base case - we are right before a leaf
      new_size = memo[[value, curr_blink]] = apply_rule(value).length
    else
      new_size = do_blinks_tree_search(apply_rule(value), num_blinks, curr_blink+1, memo)
      memo[[value, curr_blink]] = new_size
    end
    new_size
  end

  total_new_size.sum
end

###########################

def process_file(filename)
  File.read(filename).strip.split(" ").map(&:to_i)
end

puts
initial_values = process_file("day11-input-test.txt")
puts "Number of stones after 25 blinks (test): #{do_blinks(initial_values, 25).length}"

puts "Number of stones after blinks (test): #{do_blinks(initial_values, 3).length}"
puts "Number of stones after blinks (tree search test): #{do_blinks_tree_search(initial_values, 3)}"

puts
initial_values = process_file("day11-input.txt")
puts "Number of stones after 5 blinks (real): #{do_blinks(initial_values, 10).length}"
puts "Number of stones after 5 blinks tree search real): #{do_blinks_tree_search(initial_values, 10)}"
puts "Number of stones after 75 blinks (tree search real): #{do_blinks_tree_search(initial_values, 75)}"
