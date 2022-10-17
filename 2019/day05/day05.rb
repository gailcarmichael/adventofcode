class IntcodeComputer

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
	end

	def run_program(input)
		curr_pos = 0
		full_opcode = @program[curr_pos]

		while full_opcode and method(full_opcode) != :halt

			# puts "full_opcode:\t#{full_opcode}\n"
			# puts "method:\t\t\t#{method(full_opcode)}\n"

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
				opcode_input(input, @program[curr_pos+1])
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

puts "Real data:"
IntcodeComputer.new(File.read("day05-input.txt")).run_program(5)

puts "\nTest data:\n"
IntcodeComputer.new("3,9,8,9,10,9,4,9,99,-1,8").run_program(7) # should be 0
IntcodeComputer.new("3,9,8,9,10,9,4,9,99,-1,8").run_program(8) # should be 1
puts
IntcodeComputer.new("3,9,7,9,10,9,4,9,99,-1,8").run_program(7) # should be 1
IntcodeComputer.new("3,9,7,9,10,9,4,9,99,-1,8").run_program(8) # should be 0
puts
IntcodeComputer.new("3,3,1108,-1,8,3,4,3,99").run_program(7) # should be 0
IntcodeComputer.new("3,3,1108,-1,8,3,4,3,99").run_program(8) # should be 1
puts
IntcodeComputer.new("3,3,1107,-1,8,3,4,3,99").run_program(7) # should be 1
IntcodeComputer.new("3,3,1107,-1,8,3,4,3,99").run_program(8) # should be 0

