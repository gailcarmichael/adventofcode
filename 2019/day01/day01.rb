def fuel_requirements(module_masses)
	fuel_reqs = module_masses.map do |mass|
		mass / 3 - 2
	end
	fuel_reqs.reduce(:+)
end

def recursive_single_fuel_requirement(module_mass)
	return 0 if module_mass < 9

	curr_fuel_req = module_mass / 3 - 2
	curr_fuel_req + recursive_single_fuel_requirement(curr_fuel_req)
end

def recursive_fuel_requirements(module_masses)
	module_masses.inject(0) do |total_mass, mass| 
		total_mass + recursive_single_fuel_requirement(mass)
	end
end


# Test input
module_masses = File.read("day01-input-test.txt").strip.split("\n").collect{|n| n.to_i}
puts "--------"
puts "Part 1 test result: #{fuel_requirements(module_masses)}"
puts "Part 2 test result: #{recursive_fuel_requirements(module_masses)}"
puts "--------"

# Real input
module_masses = File.read("day01-input.txt").strip.split("\n").collect{|n| n.to_i}
puts "Part 1 real result: #{fuel_requirements(module_masses)}"
puts "Part 2 real result: #{recursive_fuel_requirements(module_masses)}"
puts "--------"