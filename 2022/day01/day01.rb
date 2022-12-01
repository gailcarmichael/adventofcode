def max_total_calories_of_snacks(snacks_per_elf)
    snacks_per_elf.map{|current_elf| current_elf.inject(:+)}.max
end

def sum_top_three_total_calories_of_snacks(snacks_per_elf)
    sorted = snacks_per_elf.map{|current_elf| current_elf.inject(:+)}.sort.reverse
    sorted.slice(0, 3).inject(:+)
end

####

def process_file(filename)
    snacks_per_elf = Array.new

    current_elf = Array.new
    File.read(filename).split("\n").each do |line|
        if line.empty?
            snacks_per_elf.push(current_elf)
            current_elf = Array.new
        else
            current_elf.push(line.to_i)
        end      
    end
    snacks_per_elf.push(current_elf)
  
    snacks_per_elf
end

####

snacks_per_elf_test = process_file("day01-input-test.txt")
puts "Test part 1: #{max_total_calories_of_snacks(snacks_per_elf_test)}"
puts "Test part 2: #{sum_top_three_total_calories_of_snacks(snacks_per_elf_test)}"

snacks_per_elf = process_file("day01-input.txt")
puts "Real part 1: #{max_total_calories_of_snacks(snacks_per_elf)}"
puts "Real part 2: #{sum_top_three_total_calories_of_snacks(snacks_per_elf)}"