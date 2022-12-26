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

    def nonzero_valve_neighbours_with_distance(from_valve_name)
        compute_all_pairs_shortest_paths if shortest_path_distances == nil
        result = Array.new
        shortest_path_distances.each_pair do |edge, dist|
            if edge[0] == from_valve_name && @valves[edge[1]].flow_rate > 0
                result.push([edge[1], dist])
            end
        end
        result
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
            successors = []

            @unopened_valves.each do |unopened_valve|
                distance_to_unopened_valve = @shortest_path_distances[[@curr_valve.name, unopened_valve.name]]
                successors.push(SearchSpaceState.new(
                    @shortest_path_distances,
                    Set.new(@unopened_valves.to_a - [unopened_valve]),
                    @opened_valves | Set.new([unopened_valve]),
                    unopened_valve,
                    curr_flow_rate + unopened_valve.flow_rate,
                    total_pressure_released + (curr_flow_rate*(distance_to_unopened_valve+1)),
                    steps_remaining - (1 + distance_to_unopened_valve),
                    self
                ))
            end

            # puts "Successors of #{@curr_valve.name}:"
            # successors.each {|s| p s.to_s}
            # puts

            successors
        end
    end

    def search_space_find_max_pressure(curr_state)
        if curr_state.num_unopened_valves == 0
            # after all valves are opened, we just have to tick time away for the last pressure to release
            while curr_state.steps_remaining > 0 do 
                curr_state.total_pressure_released += curr_state.curr_flow_rate
                curr_state.steps_remaining -= 1
            end
            return curr_state
        else
            # otherwise, test out going to all the other open valves and get the max
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

valve_system_real = process_file("day16-input.txt")
puts "Max pressure (real): #{valve_system_real.find_max_pressure}"