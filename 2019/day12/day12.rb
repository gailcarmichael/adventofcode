class Moon
    attr_accessor :velocity

    def initialize(x, y, z)
        @position = [x,y,z]
        @velocity = [0,0,0]
    end

    def to_s
        "pos=<#{@position[0]},#{@position[1]},#{@position[2]}>,\t\tvel=<#{@velocity[0]},#{@velocity[1]},#{@velocity[2]}>"
    end

    def pos_for_dim(dimension)
        @position[dimension]
    end

    def adjust_pos_for_dim(dimension, amount)
        @position[dimension] += amount
    end

    def vel_for_dim(dimension)
        @velocity[dimension]
    end

    def adjust_vel_for_dim(dimension, amount)
        @velocity[dimension] += amount
    end

    def adjust_pos_by_vel
        @position[0] += @velocity[0]
        @position[1] += @velocity[1]
        @position[2] += @velocity[2]
    end

    def adjust_pos_by_vel_for_dim(dimension)
        @position[dimension] += @velocity[dimension]
    end

    def potential_energy
        @position[0].abs + @position[1].abs + @position[2].abs
    end

    def kinetic_energy
        @velocity[0].abs + @velocity[1].abs + @velocity[2].abs
    end

    def total_energy
        potential_energy * kinetic_energy
    end
end

class MoonSystem
    def initialize
        @moons = Array.new
    end

    def to_s
        result = ""
        @moons.each {|moon| result += moon.to_s + "\n"}
        result
    end

    def add_moon(x,y,z)
        @moons << Moon.new(x,y,z)
        @moons.last
    end

    def apply_gravity_for_dim(dimension)
        sorted = sort_moons_by(dimension)
        sorted.each_with_index do |moon, index|
            filtered = sorted.select do |other_moon|
                moon.equal?(other_moon) || moon.pos_for_dim(dimension) != other_moon.pos_for_dim(dimension)
            end
            new_index = filtered.find_index(moon)
            moon.adjust_vel_for_dim(dimension, -1 * new_index)
            moon.adjust_vel_for_dim(dimension, (filtered.length-new_index-1)) if new_index < filtered.length-1
        end
    end

    def apply_velocity
        @moons.each {|moon| moon.adjust_pos_by_vel}
    end

    def apply_velocity_for_dim(dimension)
        @moons.each {|moon| moon.adjust_pos_by_vel_for_dim(dimension)}
    end

    def total_energy
        @moons.reduce(0) {|so_far, m| so_far + m.total_energy}
    end

    def sort_moons_by(dimension)
        @moons.sort_by {|moon| moon.pos_for_dim(dimension)}
    end

    def current_state_as_string_for_dim(dimension)
        state = ""
        @moons.each do |moon|
            state += "#{moon.pos_for_dim(dimension)}"
            state += "#{moon.vel_for_dim(dimension)}"
        end
        state
    end
end


def calculate_total_energy(system, steps)
    steps.times do 
        (0..2).each {|dim| system.apply_gravity_for_dim(dim)}
        system.apply_velocity
    end

    puts "Total energy of system: #{system.total_energy}"
end

def calculate_num_steps_before_repeat(system, dimension)
    num_steps = 0
    prev_states = Hash.new(false)
    loop do
        system.apply_gravity_for_dim(dimension)
        system.apply_velocity_for_dim(dimension)

        new_state = system.current_state_as_string_for_dim(dimension)
        
        break if (num_steps > 1 && prev_states[new_state])

        prev_states[new_state] = true

        num_steps += 1
    end
    num_steps
end


# Testing:
# system = MoonSystem.new
# system.add_moon(-1,0,2)
# system.add_moon(2,-10,-7)
# system.add_moon(4,-8,8)
# system.add_moon(3,5,-1)
# calculate_total_energy(system, 10)
# p calculate_num_steps_before_repeat(system, 0)
# p calculate_num_steps_before_repeat(system, 1)
# p calculate_num_steps_before_repeat(system, 2)

# Testing:
# system = MoonSystem.new
# system.add_moon(-8,-10,0)
# system.add_moon(5,5,10)
# system.add_moon(2,-7,3)
# system.add_moon(9,-8,-3)
# p steps_x = calculate_num_steps_before_repeat(system, 0)
# p steps_y = calculate_num_steps_before_repeat(system, 1)
# p steps_z = calculate_num_steps_before_repeat(system, 2)
# puts "lcm: #{steps_x.lcm(steps_y).lcm(steps_z)}"


# Real:
system = MoonSystem.new
system.add_moon(3,3,0)
system.add_moon(4,-16,2)
system.add_moon(-10,-6,5)
system.add_moon(-3,0,-13)
# calculate_total_energy(system, 1000)
p steps_x = calculate_num_steps_before_repeat(system, 0)
p steps_y = calculate_num_steps_before_repeat(system, 1)
p steps_z = calculate_num_steps_before_repeat(system, 2)
puts "lcm: #{steps_x.lcm(steps_y).lcm(steps_z)}"