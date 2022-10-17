OP_CODES = {1 => :+, 2 => :*, 99 => :halt}

def run_program(program)
	curr_pos = 0
	while OP_CODES[program[curr_pos]] != :halt
		program[program[curr_pos+3]] = 
			program[program[curr_pos+1]].send(OP_CODES[program[curr_pos]], 
											  program[program[curr_pos+2]])
		curr_pos += 4
	end
	program
end


def prepare_and_run_program(program, replace_1=nil, replace_2=nil)
	program = program.split(",").map{|n| n.to_i}
	program[1] = replace_1 if replace_1
	program[2] = replace_2 if replace_2
	run_program(program)
end


puts "Part 1 test results:"
File.read("day02-input-test.txt").strip.split("\n").each do |program|
	p prepare_and_run_program(program)
end

puts "\nPart 1 real results:"
p prepare_and_run_program(File.read("day02-input.txt").strip, 12, 2)

puts
orig_program = File.read("day02-input.txt").strip
found_it = false
noun = 0, verb = 0
for noun in 0..99 do
	for verb in 0..99 do
		program = orig_program.clone
		program = prepare_and_run_program(program, noun, verb)
		if program[0] == 19690720
			puts "noun, verb = #{noun}, #{verb}"
			found_it = true
			break
		end
	end
	break if found_it
end

puts "Part 2 result: #{100 * noun + verb}"
	