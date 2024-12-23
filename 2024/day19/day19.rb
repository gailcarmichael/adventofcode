require 'Set'

def design_possible?(patterns, design)
  return true if patterns.include?(design)

  curr_substring_size = 1
  loop do
    break if curr_substring_size >= design.length

    curr_substring = design[0..(curr_substring_size-1)]
    if patterns.include?(curr_substring)
      recursive_result = design_possible?(patterns, design[curr_substring_size..-1])
      return true if recursive_result
    end
    curr_substring_size += 1
  end
  return false
end

##########################

def num_possible_designs(patterns, design, memoized=Hash.new)
  num_possibilities = 0
  curr_substring_size = 1
  loop do
    break if curr_substring_size > design.length

    curr_substring = design[0..(curr_substring_size-1)]

    if curr_substring_size == design.length
      num_possibilities += 1 if patterns.include?(curr_substring)
      break
    elsif patterns.include?(curr_substring)
      next_substring = design[curr_substring_size..-1]
      result = memoized[next_substring]
      if !result
        result = num_possible_designs(patterns, next_substring, memoized)
        memoized[next_substring] = result
      end

      num_possibilities += result
    end
    curr_substring_size += 1
  end
  num_possibilities
end

##########################

def process_file(filename)
  parts = File.read(filename).strip.split("\n\n")
  {patterns: Set.new(parts[0].split(", ")), designs: parts[1].split("\n").map{|d| d.split("")}}
end

puts
data = process_file("day19-input-test.txt")
puts "Num designs that could work (test): #{data[:designs].count{|design| design_possible?(data[:patterns], design.join)}}"
puts "Num all possible designs (test): #{data[:designs].map{|design| num_possible_designs(data[:patterns], design.join)}.sum}"


puts
data = process_file("day19-input.txt")
puts "Num designs that could work (real): #{data[:designs].count{|design| design_possible?(data[:patterns], design.join)}}"
puts "Num all possible designs (real): #{data[:designs].map{|design| num_possible_designs(data[:patterns], design.join)}.sum}"
