class IntcodeComputer

    OPCODES = {1 => :opcode_add, 
                2 => :opcode_multiply,
                3 => :opcode_input,
                4 => :opcode_output,
                5 => :opcode_jump_if_true,
                6 => :opcode_jump_if_false,
                7 => :opcode_less_than,
                8 => :opcode_equals,
                9 => :opcode_adjust_relative_base,
                99 => :halt}

    NUM_INSTRUCTIONS_AFTER_OPCODE = 
               {opcode_add: 3,
                opcode_multiply: 3, 
                opcode_input: 1, 
                opcode_output: 1,
                opcode_jump_if_true: 2,
                opcode_jump_if_false: 2,
                opcode_less_than: 3,
                opcode_equals: 3,
                opcode_adjust_relative_base: 1}

    PARAM_MODE = {0 => :position, 1 => :immediate, 2 => :relative}

    def initialize(program_string)
        @program = Hash.new(0)
        program_string.split(",").map(&:to_i).each_with_index{|value, index| @program[index]=value}
    end

    def run_program(input=nil)
        curr_pos = 0
        @relative_base = 0

        full_opcode = @program[curr_pos]

        while full_opcode and method(full_opcode) != :halt

            # puts "full_opcode:\t#{full_opcode}\n"
            # puts "method:\t\t\t#{method(full_opcode)}\n"

            modified_instruction_ptr = false

            if opcode_math?(full_opcode)
                send(method(full_opcode), 
                     @program[curr_pos+1], param_mode(full_opcode, 1),
                     @program[curr_pos+2], param_mode(full_opcode, 2),
                     @program[curr_pos+3], param_mode(full_opcode, 3))
           
            elsif opcode_jump?(full_opcode)
                result = send(method(full_opcode),
                    @program[curr_pos+1], param_mode(full_opcode, 1),
                    @program[curr_pos+2], param_mode(full_opcode, 2))
                if result
                    modified_instruction_ptr = true
                    curr_pos = result
                end

            elsif method(full_opcode) == :opcode_adjust_relative_base
               opcode_adjust_relative_base(@program[curr_pos+1], param_mode(full_opcode, 1))
           
            elsif method(full_opcode) == :opcode_input
                opcode_input(input, @program[curr_pos+1], param_mode(full_opcode, 1))
            
            elsif method(full_opcode) == :opcode_output
                puts "output: #{opcode_output(@program[curr_pos+1], param_mode(full_opcode, 1))}" 
            end

            if !modified_instruction_ptr
                curr_pos += 1 + NUM_INSTRUCTIONS_AFTER_OPCODE[method(full_opcode)]
            end
            
            full_opcode = @program[curr_pos]
        end
        @program
    end

    private

    def method(full_opcode)
        OPCODES[opcode(full_opcode)]
    end

    def opcode(full_opcode)
        full_opcode % 100
    end

    def param_mode(full_opcode, param_num)
        full_opcode % (10**(param_num+2)) / (10**(param_num+1))
    end

    def param_to_value(param, mode)
        case PARAM_MODE[mode]
        when :position
            @program[param]
        when :immediate
            param
        when :relative
            @program[param+@relative_base]
        else
            puts "ERROR: #{mode} is invalid"
        end
    end

    def to_be_written_to_param_value(param, mode)
        if PARAM_MODE[mode] == :relative
            param + @relative_base
        else
            param
        end
    end

    def opcode_math?(full_opcode)
        [:opcode_add, :opcode_multiply, :opcode_less_than, :opcode_equals].
            include?(method(full_opcode))
    end

    def opcode_jump?(full_opcode)
        [:opcode_jump_if_true, :opcode_jump_if_false].
            include?(method(full_opcode))
    end

    def opcode_add(param1, param1_mode, param2, param2_mode, result, result_mode)
        param1 = param_to_value(param1, param1_mode)
        param2 = param_to_value(param2, param2_mode)
        
        @program[to_be_written_to_param_value(result, result_mode)] = param1 + param2
    end

    def opcode_multiply(param1, param1_mode, param2, param2_mode, result, result_mode)
        param1 = param_to_value(param1, param1_mode)
        param2 = param_to_value(param2, param2_mode)
        
        @program[to_be_written_to_param_value(result, result_mode)] = param1 * param2
    end

    def opcode_less_than(param1, param1_mode, param2, param2_mode, result, result_mode)
        param1 = param_to_value(param1, param1_mode)
        param2 = param_to_value(param2, param2_mode)
        
        @program[to_be_written_to_param_value(result, result_mode)] = param1 < param2 ? 1 : 0
    end

    def opcode_equals(param1, param1_mode, param2, param2_mode, result, result_mode)
        param1 = param_to_value(param1, param1_mode)
        param2 = param_to_value(param2, param2_mode)
        
        @program[to_be_written_to_param_value(result, result_mode)] = param1 == param2 ? 1 : 0
    end

    def opcode_jump_if_true(param1, param1_mode, param2, param2_mode)
        param1 = param_to_value(param1, param1_mode)
        param2 = param_to_value(param2, param2_mode)

        return param2 if param1 != 0
        return nil
    end

    def opcode_jump_if_false(param1, param1_mode, param2, param2_mode)
        param1 = param_to_value(param1, param1_mode)
        param2 = param_to_value(param2, param2_mode)

        return param2 if param1 == 0
        return nil
    end

    def opcode_adjust_relative_base(param, param_mode)
        @relative_base += param_to_value(param, param_mode)
    end

    def opcode_input(input, param, param_mode)
        @program[to_be_written_to_param_value(param, param_mode)] = input
    end

    def opcode_output(param, param_mode)
        param_to_value(param, param_mode)
    end

end

####

# puts "\n******\nTest program 1:\n\n"
# IntcodeComputer.new("109,1,204,-1,1001,100,1,100,1008,100,16,101,1006,101,0,99").run_program

# puts "\n******\nTest program 2:\n\n"
# IntcodeComputer.new("1102,34915192,34915192,7,4,7,99,0").run_program

# puts "\n******\nTest program 3:\n\n"
# IntcodeComputer.new("104,1125899906842624,99").run_program

puts "\n******\nBoost program (real data):\n\n"
IntcodeComputer.new(File.read("day09-input.txt").strip).run_program(2)






