require 'set'

class Sensor
    attr_reader :x
    attr_reader :y
    attr_reader :beacon_x
    attr_reader :beacon_y

    def initialize(x, y, closest_beacon_x, closest_beacon_y)
        @x = x
        @y = y
        @beacon_x = closest_beacon_x
        @beacon_y = closest_beacon_y
    end

    def distance_to_closest_beacon
        @dist ||= (@x - @beacon_x).abs + (@y - @beacon_y).abs
    end

    def distance_to(x,y)
        (@x - x).abs + (@y - y).abs
    end
end

class CaveTunnels
    def initialize
        @sensors = Array.new
    end

    def add_sensor(x, y, closest_beacon_x, closest_beacon_y)        
        @sensors.push(Sensor.new(x, y, closest_beacon_x, closest_beacon_y))
    end

    def where_distress_beacon_isnt_in_row(y)
        # find sensors that are vertically within their "closest beacon" distances of y
        close_sensors = @sensors.filter {|s| s.distance_to(s.x, y) <= s.distance_to_closest_beacon}

        # iterate through those sensors and make a list of positions along y where beacons can't be
        x_values = Set.new
        close_sensors.each do |sensor|
            (sensor.x-sensor.distance_to_closest_beacon).upto(sensor.x+sensor.distance_to_closest_beacon) do |x|
                if sensor.distance_to(x,y) <= sensor.distance_to_closest_beacon &&
                    !(sensor.beacon_x == x && sensor.beacon_y == y)
                    x_values.add(x)
                end
            end
        end
        x_values.to_a.sort
    end

    def find_distress_beacon(max_beacon_x, max_beacon_y)
        candidates = Set.new
        @sensors.each do |sensor|
            min_y = sensor.y - sensor.distance_to_closest_beacon
            max_y = sensor.y + sensor.distance_to_closest_beacon

            dx = 0

            (min_y-1).upto(max_y+1) do |new_y|
                next if new_y < 0 || new_y > max_beacon_y

                new_x_1 = sensor.x-dx
                new_x_2 = sensor.x+dx

                if new_x_1 >= 0 && new_x_1 <= max_beacon_x
                    candidates.add([new_x_1, new_y])
                end

                if new_x_2 >= 0 && new_x_2 <= max_beacon_x
                    candidates.add([new_x_2, new_y])
                end

                if new_y < sensor.y then dx += 1 else dx -= 1 end
            end
        end
        
        candidates.filter! do |point|
            !(@sensors.any?{|s| s.distance_to(point[0], point[1]) <= s.distance_to_closest_beacon})
        end
        candidates.to_a[0]
    end
end

def process_file(filename)
    tunnels = CaveTunnels.new
    File.read(filename).split("\n").each do |line|
        match = /Sensor at x=(-?\d+), y=(-?\d+): closest beacon is at x=(-?\d+), y=(-?\d+)/.match(line)
        tunnels.add_sensor(match[1].to_i, match[2].to_i, match[3].to_i, match[4].to_i)
    end
    tunnels
end

tunnels_test = process_file("day15-input-test.txt")
puts "Part 1 (test): #{tunnels_test.where_distress_beacon_isnt_in_row(10).size}"
distress_beacon_test = tunnels_test.find_distress_beacon(20, 20)
puts "Part 2 (test): #{distress_beacon_test[0] * 4000000 + distress_beacon_test[1]}"

tunnels_real = process_file("day15-input.txt")
puts "Part 1 (real): #{tunnels_real.where_distress_beacon_isnt_in_row(2000000).size}"
distress_beacon_real = tunnels_real.find_distress_beacon(4000000, 4000000)
puts "Part 2 (test): #{distress_beacon_real[0] * 4000000 + distress_beacon_real[1]}"