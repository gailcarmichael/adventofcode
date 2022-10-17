require 'set'

class AsteroidRegionMap
    attr_reader :map, :reverse_map

    def initialize(map_string)
        @map = Hash.new
        @reverse_map = Hash.new
        parse_map_string(map_string)
    end

    def to_s
        result = ""
        (0..(@height-1)).each do |y|
            (0..(@width-1)).each do |x|
                if @map[[x,y]] == nil
                    result += "."
                else
                    # result += "\#"
                    result += @map[[x,y]].to_s
                    # result += ('A'.ord + @map[[x,y]]).chr
                end
            end
            result += "\n"
        end
        result
    end
   
    def line_of_sight_blocked?(asteroid, asteroid_blocking, asteroid_other)
        # area of a triangle is zero when the three vertices are collinear
        # A = 0.5 * [x1 * (y2 - y3) + x2 * (y3 - y1) + x3 * (y1 - y2)]

        coord1 = @reverse_map[asteroid]
        coord2 = @reverse_map[asteroid_blocking]
        coord3 = @reverse_map[asteroid_other]

        twice_area_of_triangle =
            (coord1[0] * (coord2[1] - coord3[1])) +
            (coord2[0] * (coord3[1] - coord1[1])) +
            (coord3[0] * (coord1[1] - coord2[1]))

        second_coord_in_between?(coord1, coord2, coord3) && twice_area_of_triangle == 0
    end

    def asteroids_visible
        visible_sets = Hash.new
        asteroids_blocked.each do |asteroid_id, blocked_set|
            visible_sets[asteroid_id] = @reverse_map.keys - blocked_set.to_a - [asteroid_id]
        end

        visible_sets
    end

    def asteroids_blocked
        blocked_sets = Hash.new { |hash, key| hash[key] = Set.new }        

        trios = @reverse_map.keys.to_a.permutation(3).to_a
        trios = trios.select do |trio|
            second_coord_in_between?(@reverse_map[trio[0]], @reverse_map[trio[1]], @reverse_map[trio[2]])
        end

        trios.each do |asteroid_trio|
            if line_of_sight_blocked?(asteroid_trio[0], asteroid_trio[1], asteroid_trio[2])
                blocked_sets[asteroid_trio[0]].add(asteroid_trio[2])
            end
        end

        blocked_sets
    end

    def do_laser_blaster!(asteroid_source)
        asteroids_blasted = Array.new

        targets = asteroids_visible()[asteroid_source].to_a
        while targets.length > 0
            asteroids_blasted += targets.sort_by do |target|
                angle_for_laser_blaster(asteroid_source, target)
            end.reverse
            targets.each {|id| remove_asteroid_from_map(id)}
            
            if @reverse_map.size >= 3
                targets = asteroids_visible()[asteroid_source].to_a
            else
                targets = @reverse_map.keys - [asteroid_source]
            end
        end

        asteroids_blasted
    end

    private

    def angle_for_laser_blaster(asteroid_source, asteroid_target)
        source_coord = @reverse_map[asteroid_source]
        target_coord = @reverse_map[asteroid_target]

        # translate so origin is at source:
        target_coord = [target_coord[0]-source_coord[0], target_coord[1]-source_coord[1]]

        # reflect in x-axis so y can be up, then rotate 90 degrees (swapping x/y does both)
        temp = target_coord[0]
        target_coord[0] = target_coord[1]
        target_coord[1] = temp

        # finally, get the angle
        Math.atan2(target_coord[1], target_coord[0])
    end

    def remove_asteroid_from_map(asteroid_id)
        @map.delete(@reverse_map[asteroid_id])
        @reverse_map.delete(asteroid_id)
    end

    def second_coord_in_between?(coord1, coord2, coord3)
        x_ok = coord1[0] <= coord2[0] && coord2[0] <= coord3[0] ||
               coord3[0] <= coord2[0] && coord2[0] <= coord1[0]

        y_ok = coord1[1] <= coord2[1] && coord2[1] <= coord3[1] ||
               coord3[1] <= coord2[1] && coord2[1] <= coord1[1]

        x_ok && y_ok
    end

    def in_bounds?(x, y)
        x >= 0 && x < @width && y >= 0 && y < @width
    end

    def parse_map_string(map_string)
        lines = map_string.split("\n")
        @max_asteroid_id = -1

        @height = lines.length
        lines.each_with_index do |line, y|
            @width ||= line.length
            line.split("").each_with_index do |char, x|
                if char != "."
                    @max_asteroid_id += 1
                    @map[[x,y]] = @max_asteroid_id
                    @reverse_map[@max_asteroid_id] = [x,y]
                end
            end
        end
    end
end

# map = AsteroidRegionMap.new(File.read("day10-input-test4.txt"))
# puts map
# p map.asteroids_visible
# map.asteroids_visible.each { |id, set| puts "#{id} \t=> \t#{set.size}"  }
# p map.asteroids_visible.max_by {|id, set| set.size}

# map = AsteroidRegionMap.new(File.read("day10-input.txt"))
# visible = map.asteroids_visible
# p visible.max_by {|id, set| set.size}[0]
# p visible.max_by {|id, set| set.size}[1].length

# map = AsteroidRegionMap.new(File.read("day10-input-test6.txt"))
# p map.map[[8,2]]
# p map.do_laser_blaster!(205)[199]

map = AsteroidRegionMap.new(File.read("day10-input.txt"))
map2 = AsteroidRegionMap.new(File.read("day10-input.txt"))
id = map.do_laser_blaster!(237)[199]
puts "Coordinates of id #{id} is #{map2.reverse_map[id]}"