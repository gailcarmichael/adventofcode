require 'set'

def item_in_both(compartment1, compartment2)
    (compartment1 & compartment2).to_a[0]
end

def item_in_all(rucksacks)
    flat_rucksacks = rucksacks.map{|rucksack| Set.new(rucksack[0].to_a + rucksack[1].to_a)}
    flat_rucksacks.inject {|so_far, rucksack| so_far & rucksack}.to_a[0]
end

def priority_for_item(item)
    if item.ord <= "Z".ord
        item.ord - "A".ord + 27
    else
        item.ord - "a".ord + 1
    end
end

def sum_of_priorities(rucksacks)
    rucksacks.inject(0) do |sum, rucksack|
        sum += priority_for_item(item_in_both(rucksack[0], rucksack[1]))
    end
end

def sum_of_priorities_groups_of_three(rucksacks)
    common_items = Array.new
    rucksacks.each_slice(3) {|group| common_items.push(item_in_all(group))}
    common_items.inject(0) {|sum, item| sum + priority_for_item(item)}
end


def process_file(filename)
    rucksacks = Array.new
    File.read(filename).strip.split("\n").map{|line| line.split("")}.each do |items|
        compartment1 = Set.new(items.slice(0..items.size/2-1))
        compartment2 = Set.new(items.slice(items.size/2..-1))
        rucksacks.push([compartment1, compartment2])
    end
    rucksacks
end

rucksacks_test = process_file("day03-input-test.txt")
rucksacks_real = process_file("day03-input.txt")

puts "Sum of priorities (test): #{sum_of_priorities(rucksacks_test)}"
puts "Sum of priorities (real): #{sum_of_priorities(rucksacks_real)}"

puts "Sum of priorities for badges (test): #{sum_of_priorities_groups_of_three(rucksacks_test)}"
puts "Sum of priorities for badges (real): #{sum_of_priorities_groups_of_three(rucksacks_real)}"