def get_total_distance(list1, list2)
  list1.sort!
  list2.sort!

  distance_list = []
  list1.each_with_index do |num1, index|
    distance_list.push((num1-list2[index]).abs)
  end

  distance_list.inject(:+)
end


def get_similarity_score(list1, list2)
  list2_hash = Hash.new(0)
  list2.each do |num2|
    list2_hash[num2] += 1
  end

  list1.map do |num1|
    num1 * list2_hash[num1]
  end.inject(:+)
end


def process_file(filename)
  list1 = []
  list2 = []
  File.read(filename).strip.split("\n").each do |line|
    list1.push(line.split[0].to_i)
    list2.push(line.split[1].to_i)
  end
  [list1, list2]
end

puts
test_lists = process_file("day01-input-test.txt")
puts "Total distance (test): #{get_total_distance(test_lists[0], test_lists[1])}"
puts "Total similarity (test): #{get_similarity_score(test_lists[0], test_lists[1])}"

puts
real_lists = process_file("day01-input.txt")
puts "Total distance (test): #{get_total_distance(real_lists[0], real_lists[1])}"
puts "Total similarity (test): #{get_similarity_score(real_lists[0], real_lists[1])}"
