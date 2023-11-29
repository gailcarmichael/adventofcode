require 'set'

class Valve
    attr_accessor :name, :flow_rate, :neighbours

    def initialize(name, flow_rate, neighbour_names)
        @name = name
        @flow_rate = flow_rate
        @neighbours = neighbour_names
    end
end

class ValveSystem
    def initialize
        @valves = Hash.new
        
    end

    def add_valve(name, flow_rate, neighbour_names)
        @valves[name] = Valve.new(name, flow_rate, neighbour_names)
    end

    def [](key)
        @valves[key]
    end

    def num_openable_valves
        @num_openable_valves ||= @valves.values.filter{|v| v.flow_rate > 0}.count
    end

    def find_max_pressure
        all_non_zero_valves = Set.new(@valves.values.filter{|v| v.flow_rate > 0})

        initial_state = SearchSpaceState.new(
            compute_all_pairs_shortest_paths,
            all_non_zero_valves, Set.new, @valves["AA"],
            0, 0,
            30,
            nil)

        max_pressure_state = search_space_find_max_pressure(initial_state)

        # state_to_print = max_pressure_state
        # loop do
        #     puts "#{state_to_print}"
        #     state_to_print = state_to_print.parent_state
        #     break if state_to_print == nil
        # end

        max_pressure_state.total_pressure_released
    end

    def find_max_pressure_parallelized
        all_non_zero_valves = @valves.values.filter{|v| v.flow_rate > 0}
        max_pressures = []

        1.upto(all_non_zero_valves.count/2+1) do |how_many_first_set|

            all_non_zero_valves.combination(how_many_first_set).each do |first_set|
                second_set = all_non_zero_valves - first_set

                initial_state_1 = SearchSpaceState.new(
                    compute_all_pairs_shortest_paths,
                    Set.new(first_set), Set.new, @valves["AA"],
                    0, 0,
                    26,
                    nil)

                max_pressure_state_1 = search_space_find_max_pressure(initial_state_1)

                initial_state_2 = SearchSpaceState.new(
                    compute_all_pairs_shortest_paths,
                    Set.new(second_set), Set.new, @valves["AA"],
                    0, 0,
                    26,
                    nil)

                max_pressure_state_2 = search_space_find_max_pressure(initial_state_2)

                max_pressures.push(max_pressure_state_1.total_pressure_released + max_pressure_state_2.total_pressure_released)
            end
        end
        max_pressures.max
    end

    def compute_all_pairs_shortest_paths        
        shortest_path_distances = Hash.new(99999)

        @valves.values.each do |valve|
            shortest_path_distances[[valve.name, valve.name]] = 0
            valve.neighbours.each do |neighbour_value_name|
                shortest_path_distances[[valve.name, neighbour_value_name]] = 1
                shortest_path_distances[[neighbour_value_name, valve.name]] = 1
            end
        end

        @valves.values.each do |k_valve|
            @valves.values.each do |i_valve|
                @valves.values.each do |j_valve|

                    if (shortest_path_distances[[i_valve.name, j_valve.name]] >
                            shortest_path_distances[[i_valve.name, k_valve.name]] +
                            shortest_path_distances[[k_valve.name, j_valve.name]])

                        shortest_path_distances[[i_valve.name, j_valve.name]] =
                            shortest_path_distances[[i_valve.name, k_valve.name]] +
                            shortest_path_distances[[k_valve.name, j_valve.name]]

                    end
                end
            end
        end

        shortest_path_distances
    end

    private

    class SearchSpaceState
        attr_reader :curr_flow_rate, :curr_valve, :parent_state
        attr_accessor :total_pressure_released, :steps_remaining

        def initialize(shortest_path_distances,
                       unopened_valves, opened_valves, curr_valve,
                       curr_flow_rate, total_pressure_released,
                       steps_remaining,
                       parent_state)
            
            @shortest_path_distances = shortest_path_distances
            @unopened_valves = unopened_valves
            @opened_valves = opened_valves
            @curr_valve = curr_valve
            @curr_flow_rate = curr_flow_rate
            @total_pressure_released = total_pressure_released
            @steps_remaining = steps_remaining
            @parent_state = parent_state
        end

        def to_s
            "Valve=#{@curr_valve.name}, curr_flow_rate=#{@curr_flow_rate}, total_pressure_released=#{@total_pressure_released}, steps_remaining=#{@steps_remaining}"
        end

        def num_opened_valves
            @opened_valves.count
        end

        def num_unopened_valves
            @unopened_valves.count
        end

        def was_valve_opened?(valve_name)
            @opened_valves.include?(valve_name)
        end

        def successors
            next_successors = []

            @unopened_valves.each do |unopened_valve|
                distance_to_unopened_valve = @shortest_path_distances[[@curr_valve.name, unopened_valve.name]]
                
                steps_remaining_after_going_to_unopened = steps_remaining - (1 + distance_to_unopened_valve)
                next if steps_remaining_after_going_to_unopened < 0

                next_successors.push(SearchSpaceState.new(
                    @shortest_path_distances,
                    Set.new(@unopened_valves.to_a - [unopened_valve]),
                    Set.new(@opened_valves.to_a + [unopened_valve]),
                    unopened_valve,
                    curr_flow_rate + unopened_valve.flow_rate,
                    total_pressure_released + (curr_flow_rate * (1 + distance_to_unopened_valve)),
                    steps_remaining_after_going_to_unopened,
                    self
                ))
            end

            if next_successors.empty?
                next_successors.push(SearchSpaceState.new(
                    @shortest_path_distances,
                    Set.new(@unopened_valves),
                    Set.new(@opened_valves),
                    @curr_valve,
                    curr_flow_rate,
                    total_pressure_released + curr_flow_rate,
                    steps_remaining - 1,
                    self
                ))
            end

            # puts "Successors of #{@curr_valve.name}:"
            # next_successors.each {|s| p s.to_s}
            # puts

            next_successors
        end

        def release_pressure_for_remaining_steps
            while @steps_remaining > 0 do 
                @total_pressure_released += @curr_flow_rate
                @steps_remaining -= 1
            end
        end
    end

    def search_space_find_max_pressure(curr_state)
        if curr_state.steps_remaining == 0
            # ran out of time, return where we're at
            return curr_state
        end
        
        if curr_state.num_unopened_valves == 0
            # after all valves are opened, we just have to tick time away for the last pressure to release
            curr_state.release_pressure_for_remaining_steps
            return curr_state
        else
            # otherwise, test out going to all the other open valves we can reach in time, and get the max
            max_pressure_so_far = 0
            max_pressure_state = nil

            curr_state.successors.each do |successor|
                max_pressure_sucessor = search_space_find_max_pressure(successor)
                
                if max_pressure_so_far < max_pressure_sucessor.total_pressure_released
                    max_pressure_so_far = max_pressure_sucessor.total_pressure_released
                    max_pressure_state = max_pressure_sucessor
                end
            end

            return max_pressure_state
        end
    end
end

def process_file(filename)
    valve_system = ValveSystem.new
    File.read(filename).split("\n").each do |line|
        match = /Valve ([A-Z]+) has flow rate=(\d+); tunnels? leads? to valves? (.+)/.match(line)
        valve_system.add_valve(match[1], match[2].to_i, match[3].split(",").map{|v| v.strip})
    end
    valve_system
end

valve_system_test = process_file("day16-input-test.txt")
puts "Max pressure (test): #{valve_system_test.find_max_pressure}"
puts "Max pressure parallelized (test): #{valve_system_test.find_max_pressure_parallelized}"

puts
valve_system_real = process_file("day16-input.txt")
puts "Max pressure (real): #{valve_system_real.find_max_pressure}"
puts "Max pressure parallelized (real): #{valve_system_real.find_max_pressure_parallelized}"