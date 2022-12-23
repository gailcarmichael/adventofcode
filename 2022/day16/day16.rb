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
        initial_state = HillClimbState.new(self, [], @valves["AA"], :start, 0, 0, nil)
        (1..1000000).map { hill_climb_max_pressure(initial_state, 30)}.max
    end

    private

    class HillClimbState
        attr_reader :total_pressure_released, :valve, :parent_state

        def initialize(valve_system, opened_valves, valve, action, curr_flow_rate, total_pressure_released, parent_state)
            @valve_system = valve_system
            @opened_valves = opened_valves
            @valve = valve
            @action = action
            @curr_flow_rate = curr_flow_rate
            @total_pressure_released = total_pressure_released
            @parent_state = parent_state
        end

        def to_s
            "Valve=#{@valve.name}, action=#{@action}, curr_flow_rate=#{@curr_flow_rate}, total_pressure_released=#{@total_pressure_released}"
        end

        def num_opened_valves
            @opened_valves.count
        end

        def was_valve_opened?(valve_name)
            @opened_valves.include?(valve_name)
        end

        def successors
            successors = []

            # if we've already opened all the valves, we should just sit at the current location
            if @valve_system.num_openable_valves == num_opened_valves
                return [HillClimbState.new(
                    @valve_system, 
                    @opened_valves, 
                    @valve, 
                    :stay, 
                    @curr_flow_rate,
                    @total_pressure_released + @curr_flow_rate,
                    self
                )]
            end

            ###

            # one successor action is simply opening the valve at the current location
            # if it's non-zero and not already open
            if !was_valve_opened?(@valve.name) && @valve.flow_rate > 0
                successors.push(HillClimbState.new(
                    @valve_system,
                    @opened_valves + [@valve.name],
                    @valve,
                    :open_valve,
                    @curr_flow_rate + @valve.flow_rate,
                    @total_pressure_released + @curr_flow_rate,
                    self
                ))
            end

            # the other successor actions are moving to the neighbouring valves
            valve.neighbours.each do |neighbour_value_name|
                successors.push(HillClimbState.new(
                    @valve_system,
                    @opened_valves,
                    @valve_system[neighbour_value_name],
                    :move_location,
                    @curr_flow_rate,
                    @total_pressure_released + @curr_flow_rate,
                    self
                ))
            end

            # puts "Successors of #{@valve.name}:"
            # successors.each {|s| p s.to_s}
            # puts

            successors
        end
    end

    def hill_climb_max_pressure(curr_state, num_steps_left)
        if num_steps_left == 0
            # if curr_state.num_opened_valves >= 6
                # puts
                # state_to_print = curr_state
                # loop do
                #     break if state_to_print == nil
                #     puts state_to_print.to_s
                #     state_to_print = state_to_print.parent_state
                # end
            # end
            return curr_state.total_pressure_released 
        end

        max_pressure_so_far = 0
        successors = curr_state.successors

        # successors.each do |successor|
        #     new_pressure = hill_climb_max_pressure(successor, num_steps_left-1)
        #     max_pressure_so_far = [max_pressure_so_far, new_pressure].max
        # end

        new_pressure = hill_climb_max_pressure(successors.sample, num_steps_left-1)
        max_pressure_so_far = [max_pressure_so_far, new_pressure].max

        return max_pressure_so_far
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
p valve_system_test.find_max_pressure