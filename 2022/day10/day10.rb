def signal_strength_to_add(cycle_num, register_X)
    if [20, 60, 100, 140, 180, 220].include?(cycle_num)
        (cycle_num * register_X)
    else
        0
    end
end

def updated_crt_output(old_output, cycle_num, register_X)
    crt_row = (cycle_num-1)/40
    crt_col = (cycle_num-1) % 40

    new_output = old_output
    new_output += "\n" if crt_col == 0 && crt_row > 0

    if (register_X-crt_col).abs < 2
        new_output += "#"
    else
        new_output += "."
    end

    new_output
end

def simulate_instructions(instruction_list)
    
    sum_signal_strengths = 0
    crt_output = ""
    
    cycle_num = 0
    register_X = 1

    instruction_list.each do |instruction|
        operator = instruction[0]
        value = instruction[1]
        cycle_num += 1

        sum_signal_strengths += signal_strength_to_add(cycle_num, register_X)
        crt_output = updated_crt_output(crt_output, cycle_num, register_X)

        if operator == "addx"
            cycle_num += 1
            sum_signal_strengths += signal_strength_to_add(cycle_num, register_X)
            crt_output = updated_crt_output(crt_output, cycle_num, register_X)
            register_X += value
        end
    end

    puts crt_output

    sum_signal_strengths
end

########

def process_file(filename)
    File.read(filename).split("\n").map do |line|
        instruction_parts = line.split(" ")
        [instruction_parts[0], instruction_parts[1].to_i]
    end
end

puts "Signal-strength result (test): #{simulate_instructions(process_file("day10-input-test.txt"))}"
puts "Signal-strength result (real): #{simulate_instructions(process_file("day10-input.txt"))}"