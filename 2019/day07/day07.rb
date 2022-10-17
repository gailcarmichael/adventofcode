require 'concurrent'

class IntcodeComputer

    attr_reader :last_output, :inputs
    attr_accessor :program_to_give_output, :program_index

	OPCODES = {1 => :opcode_add, 
				2 => :opcode_multiply,
				3 => :opcode_input,
				4 => :opcode_output,
				5 => :opcode_jump_if_true,
				6 => :opcode_jump_if_false,
				7 => :opcode_less_than,
				8 => :opcode_equals,
				99 => :halt}

	NUM_INSTRUCTIONS_AFTER_OPCODE = 
	           {opcode_add: 3,
	           	opcode_multiply: 3, 
	           	opcode_input: 1, 
	           	opcode_output: 1,
	           	opcode_jump_if_true: 2,
	           	opcode_jump_if_false: 2,
	            opcode_less_than: 3,
	        	opcode_equals: 3}

	PARAM_MODE = {0 => :position, 1 => :immediate}

	def initialize(program_string)
		@program = program_string.split(",").map(&:to_i)
        @inputs = Concurrent::Array.new
        @program_to_give_output = nil
        @last_output = nil
        @program_index
	end

    def provide_new_input(input)
        @inputs << input
    end

	def run_program
		curr_pos = 0
		full_opcode = @program[curr_pos]
        next_input_index = 0

		while full_opcode and method(full_opcode) != :halt

			modified_instruction_ptr = false

			if opcode_math?(full_opcode)
				send(method(full_opcode), 
					 @program[curr_pos+1], param_mode(full_opcode, 1),
					 @program[curr_pos+2], param_mode(full_opcode, 2),
					 @program[curr_pos+3])
			
            elsif opcode_jump?(full_opcode)
				result = send(method(full_opcode),
					@program[curr_pos+1], param_mode(full_opcode, 1),
					@program[curr_pos+2], param_mode(full_opcode, 2))
				if result
					modified_instruction_ptr = true
					curr_pos = result
				end
			
            elsif method(full_opcode) == :opcode_input
                sleep(0.01) until @inputs[next_input_index] != nil
				opcode_input(@inputs[next_input_index], @program[curr_pos+1])
                next_input_index += 1
			
            elsif method(full_opcode) == :opcode_output
                @last_output = opcode_output(@program[curr_pos+1], param_mode(full_opcode, 1))
                if program_to_give_output != nil
                    program_to_give_output.provide_new_input(last_output)
                end
			end

			if !modified_instruction_ptr
				curr_pos += 1 + NUM_INSTRUCTIONS_AFTER_OPCODE[method(full_opcode)]
			end
			
			full_opcode = @program[curr_pos]
		end
		last_output
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

	def opcode_math?(full_opcode)
		[:opcode_add, :opcode_multiply, :opcode_less_than, :opcode_equals].
			include?(method(full_opcode))
	end

	def opcode_jump?(full_opcode)
		[:opcode_jump_if_true, :opcode_jump_if_false].
			include?(method(full_opcode))
	end

	def opcode_add(param1, param1_mode, param2, param2_mode, result)
		param1 = @program[param1] if PARAM_MODE[param1_mode] == :position
		param2 = @program[param2] if PARAM_MODE[param2_mode] == :position
		
		@program[result] = param1 + param2
	end

	def opcode_multiply(param1, param1_mode, param2, param2_mode, result)
		param1 = @program[param1] if PARAM_MODE[param1_mode] == :position
		param2 = @program[param2] if PARAM_MODE[param2_mode] == :position
		
		@program[result] = param1 * param2
	end

	def opcode_less_than(param1, param1_mode, param2, param2_mode, result)
		param1 = @program[param1] if PARAM_MODE[param1_mode] == :position
		param2 = @program[param2] if PARAM_MODE[param2_mode] == :position
		
		@program[result] = param1 < param2 ? 1 : 0
	end

	def opcode_equals(param1, param1_mode, param2, param2_mode, result)
		param1 = @program[param1] if PARAM_MODE[param1_mode] == :position
		param2 = @program[param2] if PARAM_MODE[param2_mode] == :position
		
		@program[result] = param1 == param2 ? 1 : 0
	end

	def opcode_jump_if_true(param1, param1_mode, param2, param2_mode)
		param1 = @program[param1] if PARAM_MODE[param1_mode] == :position
		param2 = @program[param2] if PARAM_MODE[param2_mode] == :position

		return param2 if param1 != 0
		return nil
	end

	def opcode_jump_if_false(param1, param1_mode, param2, param2_mode)
		param1 = @program[param1] if PARAM_MODE[param1_mode] == :position
		param2 = @program[param2] if PARAM_MODE[param2_mode] == :position

		return param2 if param1 == 0
		return nil
	end

	def opcode_input(input, position)
		@program[position] = input
	end

	def opcode_output(param, param_mode)
		param = @program[param] if PARAM_MODE[param_mode] == :position
		param
	end

end

####

def get_max_thruster_signal(program_string)
    original_program = IntcodeComputer.new(program_string)

    max_result = 0
    [0,1,2,3,4].permutation.each do |phases|
        prev_output = 0
        phases.each do |phase|
            program = Marshal.load(Marshal.dump(original_program)) # deep copy
            program.provide_new_input(phase)
            program.provide_new_input(prev_output)
            prev_output = program.run_program()
        end
        max_result = [max_result, prev_output].max
    end
    puts "Max result is #{max_result}"
end

# get_max_thruster_signal("3,15,3,16,1002,16,10,16,1,16,15,15,4,15,99,0,0")
# get_max_thruster_signal("3,23,3,24,1002,24,10,24,1002,23,-1,23, 101,5,23,23,1,24,23,23,4,23,99,0,0")
# get_max_thruster_signal("3,31,3,32,1002,32,10,32,1001,31,-2,31,1007,31,0,33,1002,33,7,33,1,33,31,31,1,32,31,31,4,31,99,0,0,0")

# get_max_thruster_signal(File.read("day07-input.txt").strip)


####

def get_max_thruster_signal_feedback_loop_mode(program_string)
    original_program = IntcodeComputer.new(program_string)

    max_result = 0
    [5,6,7,8,9].permutation.each do |phases|
        amp_programs = []
        
        phases.each_with_index do |phase, index|
            program = Marshal.load(Marshal.dump(original_program)) # deep copy
            program.program_index = index
            program.provide_new_input(phase)
            program.provide_new_input(0) if index == 0
            amp_programs << program
        end
        
        amp_programs.each_with_index do |program, index|
            program.program_to_give_output = amp_programs[(index + 1) % amp_programs.length]
        end

        threads = []
        amp_programs.each do |program|
           threads << Thread.new { program.run_program }
        end
        threads.each(&:join)

        max_result = [amp_programs.last.last_output, max_result].max
    end
    puts "Max result for feedback loop mode: #{max_result}"
end

# get_max_thruster_signal_feedback_loop_mode("3,26,1001,26,-4,26,3,27,1002,27,2,27,1,27,26,27,4,27,1001,28,-1,28,1005,28,6,99,0,0,5")
# get_max_thruster_signal_feedback_loop_mode("3,52,1001,52,-5,52,3,53,1,52,56,54,1007,54,5,55,1005,55,26,1001,54,-5,54,1105,1,12,1,53,54,53,1008,54,0,55,1001,55,1,55,2,53,55,53,4,53,1001,56,-1,56,1005,56,6,99,0,0,0,0,10")

get_max_thruster_signal_feedback_loop_mode(File.read("day07-input.txt").strip)
