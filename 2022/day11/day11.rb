class Monkey
    attr_reader :items
    attr_reader :num_times_inspected_items
    attr_reader :divisible_by

    def initialize(items, operator, operand, divisible_by, true_throw, false_throw)
        @items = items
        @operator = operator
        @operand = operand
        @divisible_by = divisible_by
        @true_throw = true_throw
        @false_throw = false_throw

        @num_times_inspected_items = 0
    end

    def take_turn(monkey_sim, divide_by_three=true)
        @items.each do |worry_level|   
            @num_times_inspected_items += 1
            
            operand_value = (if @operand == "old" then worry_level else @operand.to_i end)
            worry_level = worry_level.send(@operator, operand_value)

            worry_level = worry_level / 3 if divide_by_three

            worry_level = worry_level % monkey_sim.LCM

            if worry_level % @divisible_by == 0
                monkey_sim.throw_item_to_monkey(worry_level, @true_throw)
            else
                monkey_sim.throw_item_to_monkey(worry_level, @false_throw)
            end
        end
        @items = []
    end

    def receive_item(item_value)
        @items.push(item_value)
    end
end

class MonkeyBusinessSim
    attr_reader :monkey_list
    attr_reader :LCM

    def initialize(monkey_list)
        @monkey_list = monkey_list

        @LCM = monkey_list.inject(1) {|so_far, monkey| so_far * monkey.divisible_by}
    end

    def throw_item_to_monkey(item_value, monkey_num)
        @monkey_list[monkey_num].receive_item(item_value)
    end

    def do_rounds(num_rounds, divide_by_three=true)
        num_rounds.times { @monkey_list.each {|m| m.take_turn(self, divide_by_three)} }
    end
end

######

def process_file(filename)
    MonkeyBusinessSim.new(File.read(filename).split("\n\n").map do |monkey_lines_all|
        monkey_lines = monkey_lines_all.split("\n")
        Monkey.new(
            monkey_lines[1][18..-1].split(",").map {|item| item.strip.to_i},
            monkey_lines[2][23].to_sym,
            monkey_lines[2][25..-1],
            monkey_lines[3][21..-1].to_i,
            monkey_lines[4][29..-1].to_i,
            monkey_lines[5][30..-1].to_i)
    end)
end

monkeys_test = process_file("day11-input-test.txt")
monkeys_test.do_rounds(20)
inspection_numbers = monkeys_test.monkey_list.map{|m| m.num_times_inspected_items}.sort.reverse
puts "Monkey business (test): #{inspection_numbers[0] * inspection_numbers[1]}"

monkeys_test = process_file("day11-input-test.txt")
monkeys_test.do_rounds(10000, divide_by_three=false)
inspection_numbers = monkeys_test.monkey_list.map{|m| m.num_times_inspected_items}.sort.reverse
puts "Monkey business 10000 rounds (test): #{inspection_numbers[0] * inspection_numbers[1]}"

monkeys_real = process_file("day11-input.txt")
monkeys_real.do_rounds(20)
inspection_numbers = monkeys_real.monkey_list.map{|m| m.num_times_inspected_items}.sort.reverse
puts "Monkey business (real): #{inspection_numbers[0] * inspection_numbers[1]}"

monkeys_real = process_file("day11-input.txt")
monkeys_real.do_rounds(10000, divide_by_three=false)
inspection_numbers = monkeys_real.monkey_list.map{|m| m.num_times_inspected_items}.sort.reverse
puts "Monkey business 10000 rounds (test): #{inspection_numbers[0] * inspection_numbers[1]}"