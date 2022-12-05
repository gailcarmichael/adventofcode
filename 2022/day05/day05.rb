class Crate
    attr_reader :name

    def initialize(name)
        @name = name
    end

    def to_s
        "[#{@name}]"
    end
end


class CrateStacks
    def initialize
        @stacks = Hash.new{|h,k| h[k] = Array.new}
    end

    def push_crate(crate, stack_num)
        @stacks[stack_num].push(crate)
    end

    def push_crates(crate_list, stack_num)
        @stacks[stack_num] = @stacks[stack_num].concat(crate_list)
    end

    def pop_crate(stack_num)
        @stacks[stack_num].pop
    end

    def pop_crates(stack_num, how_many)
        popped = Array.new
        (1..how_many).each do |count|
            popped.push(@stacks[stack_num].pop)
        end
        popped.reverse
    end

    def crates_names_at_top_of_stacks
        @stacks.values.map do |stack|
            if stack[-1]
                stack[-1].name
            else
                ""
            end
        end
    end

    def to_s
        @stacks.keys.sort.map do |key|
            @stacks[key].map(&:to_s).join("")
        end.join("\n")
    end
end


class Instruction
    attr_reader :how_many
    attr_reader :stack_num_from
    attr_reader :stack_num_to

    def initialize(how_many, stack_num_from, stack_num_to)
        @how_many = how_many
        @stack_num_from = stack_num_from
        @stack_num_to = stack_num_to
    end
end


class CraneSim
    attr_reader :crate_stacks
    attr_reader :instructions

    def initialize(crate_stacks, instructions)
        @crate_stacks = crate_stacks
        @instructions = instructions
    end

    def apply_instructions_to_stacks
        @instructions.each do |instruction|
            (1..instruction.how_many).each do |crate_num|
                @crate_stacks.push_crate(
                    @crate_stacks.pop_crate(instruction.stack_num_from),
                    instruction.stack_num_to)
            end
        end
    end

    def apply_instructions_to_stacks_v2
        @instructions.each do |instruction|
            @crate_stacks.push_crates(
                @crate_stacks.pop_crates(instruction.stack_num_from, instruction.how_many),
                instruction.stack_num_to)
        end
    end
end

##################

def process_crates_string(crates_string)
    stacks = CrateStacks.new
    crates_string.split("\n")[0..-2].reverse.each do |line|
        whitespace_since_prev_crate = 0
        last_crate_stack = 0
        line.each_char do |char|
            if char == " "
                whitespace_since_prev_crate += 1
            elsif char == "["
                last_crate_stack += 1
                if whitespace_since_prev_crate > 1
                    last_crate_stack += (whitespace_since_prev_crate/4)
                end
            elsif char == "]"
                whitespace_since_prev_crate = 0
            else
                stacks.push_crate(Crate.new(char), last_crate_stack)
            end
        end
    end
    stacks
end

def process_instructions_string(instruction_strings)
    instruction_strings.split("\n").map do |line|
        line_parts = line.split(" ")
        Instruction.new(line_parts[1].to_i, line_parts[3].to_i, line_parts[5].to_i)
    end
end

def process_file(filename)
    file_parts = File.read(filename).split("\n\n")
    CraneSim.new(process_crates_string(file_parts[0]), process_instructions_string(file_parts[1]))
end

crane_sim_test = process_file("day05-input-test.txt")
crane_sim_test.apply_instructions_to_stacks
puts "Crates at top (test): #{crane_sim_test.crate_stacks.crates_names_at_top_of_stacks.join("")}"

crane_sim_real = process_file("day05-input.txt")
crane_sim_real.apply_instructions_to_stacks
puts "Crates at top (real): #{crane_sim_real.crate_stacks.crates_names_at_top_of_stacks.join("")}"

crane_sim_test = process_file("day05-input-test.txt")
crane_sim_test.apply_instructions_to_stacks_v2
puts "Crates at top (test): #{crane_sim_test.crate_stacks.crates_names_at_top_of_stacks.join("")}"

crane_sim_real = process_file("day05-input.txt")
crane_sim_real.apply_instructions_to_stacks_v2
puts "Crates at top (real): #{crane_sim_real.crate_stacks.crates_names_at_top_of_stacks.join("")}"