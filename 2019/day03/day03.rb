require 'set'

class Grid
	def initialize(wire_1_path, wire_2_path)
		@grid = Hash.new{|hash, key| hash[key] = Set.new}
		@steps_wire_1 = Hash.new(0)
		@steps_wire_2 = Hash.new(0)
		add_wire_to_grid(wire_1_path, 1, @steps_wire_1)
		add_wire_to_grid(wire_2_path, 2, @steps_wire_2)
	end

	def intersection_points
		@grid.select{|coord, path_ids| path_ids.size == 2}
	end

	def closest_intersection_point
		intersection_points.min_by{|coord, _| coord[0].abs + coord[1].abs}[0]
	end

	def min_signal_num_steps
		coord = intersection_points.min_by{|coord, _| @steps_wire_1[coord] + @steps_wire_2[coord]}[0]
		@steps_wire_1[coord] + @steps_wire_2[coord]
	end

	private

	DX_FOR_DIRECTION = {'U' => 0, 'L' => -1, 'D' =>  0, 'R' => 1}
	DY_FOR_DIRECTION = {'U' => 1, 'L' =>  0, 'D' => -1, 'R' => 0}

	def add_wire_to_grid(wire_path, path_id, steps)
		curr_x = curr_y = 0
		step_count = 0
		wire_path.split(",").each do |move|
			m = /([ULDR])(.*)/.match(move)
			dx = DX_FOR_DIRECTION[m[1]]
			dy = DY_FOR_DIRECTION[m[1]]

			1.upto(m[2].to_i).each do |i|
				curr_x += dx
				curr_y += dy
				@grid[[curr_x, curr_y]].add(path_id)

				step_count += 1
				steps[[curr_x, curr_y]] = step_count if steps[[curr_x, curr_y]] == 0
			end
		end
	end
end

def part1_solution_for(path_1, path_2)
	Grid.new(path_1, path_2).closest_intersection_point
end

def part2_solution_for(path_1, path_2)
	Grid.new(path_1, path_2).min_signal_num_steps
end


puts "Part 1 test solutions:"
p part1_solution_for('R8,U5,L5,D3', 'U7,R6,D4,L4')
p part1_solution_for('R75,D30,R83,U83,L12,D49,R71,U7,L72', 'U62,R66,U55,R34,D71,R55,D58,R83')
p part1_solution_for('R98,U47,R26,D63,R33,U87,L62,D20,R33,U53,R51', 'U98,R91,D20,R16,D67,R40,U7,R15,U6,R7')

puts "\nPart 1 real solution:"
lines = File.read("day03-input.txt").split("\n")
p part1_solution_for(lines[0], lines[1])

puts "\nPart 2 test solutions:"
p part2_solution_for('R8,U5,L5,D3', 'U7,R6,D4,L4')
p part2_solution_for('R8,U5,L5,D3,R3,U4,L3,D3', 'U7,R6,D4,L4')
p part2_solution_for('R75,D30,R83,U83,L12,D49,R71,U7,L72', 'U62,R66,U55,R34,D71,R55,D58,R83')
p part2_solution_for('R98,U47,R26,D63,R33,U87,L62,D20,R33,U53,R51', 'U98,R91,D20,R16,D67,R40,U7,R15,U6,R7')

puts "\nPart 2 real solution:"
p part2_solution_for(lines[0], lines[1])