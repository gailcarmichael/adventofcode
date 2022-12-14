class Caves
    def initialize
        @rocks = Hash.new(false)
        @sands = Hash.new(false)
        @source = [500,0]

        @min_x = @max_x = 500
        @min_y = @max_y = 0

        @floor = nil
    end

    def occupied?(x, y)
        @rocks[[x,y]] || @sands[[x,y]] || (@floor && y == @floor)
    end

    def to_s
        result = ""
        @min_y.upto(@max_y) do |y|
            @min_x.upto(@max_x) do |x|
                if @rocks[[x,y]]
                    result += "#"
                elsif @source == [x,y]
                    result += "+"
                elsif @sands[[x,y]]
                    result += "o"
                else
                    result += "."
                end
            end
            result += "\n"
        end
        result
    end

    def add_rock_line(start_point, end_point)
        if start_point[0] == end_point[0]
            [start_point[1], end_point[1]].min.upto([start_point[1], end_point[1]].max) do |y|
                add_rock(start_point[0], y)
            end
        elsif start_point[1] == end_point[1]
            [start_point[0], end_point[0]].min.upto([start_point[0], end_point[0]].max) do |x|
                add_rock(x, start_point[1])
            end
        else
            raise "Invalid line in start/end points provided to add_rock_line"
        end
    end

    def add_floor
        @floor = @max_y + 2
        @max_y = @floor
    end

    def reset_sand
        @sands = Hash.new(false)
    end

    def how_many_sands_can_drop
        count = 0
        loop do
            break if !drop_one_sand
            count += 1
        end 
        count
    end

    def add_rock(x, y)
        @rocks[[x, y]] = true

        @max_x = [@max_x, x].max
        @min_x = [@min_x, x].min

        @max_y = [@max_y, y].max
        @min_y = [@min_y, y].min
    end

    def drop_one_sand
        return drop_one_sand_from(@source)
    end

    private 
    
    def drop_one_sand_from(source)
        new_sand = source

        if occupied?(@source[0], @source[1])
            return false
        end

        while !occupied?(new_sand[0], new_sand[1]+1) && (new_sand[1]+1 <= @max_y)
            new_sand = [new_sand[0], new_sand[1]+1]
        end

        if new_sand[1] <= @max_y # otherwise, falling into the abyss!
            if !occupied?(new_sand[0]-1, new_sand[1]+1)
                return drop_one_sand_from([new_sand[0]-1, new_sand[1]+1])

            elsif !occupied?(new_sand[0]+1, new_sand[1]+1)
                return drop_one_sand_from([new_sand[0]+1, new_sand[1]+1])
            
            else
                @sands[new_sand] = true

                @max_x = [@max_x, new_sand[0]].max
                @min_x = [@min_x, new_sand[0]].min

                @max_y = [@max_y, new_sand[1]].max
                @min_y = [@min_y, new_sand[1]].min

                return true
            end
        else
            return false
        end
    end
end

def process_file(filename)
    caves = Caves.new
    File.read(filename).split("\n").each do |line|
        points = line.split(" -> ")
        prev_point = points[0].split(",").map(&:to_i)
        points[1..-1].each do |point|
            next_point = point.split(",").map(&:to_i)
            caves.add_rock_line(prev_point, next_point)
            prev_point = next_point
        end
    end
    caves
end

cave_test = process_file("day14-input-test.txt")
puts "Number of sands before falling into void (test): #{cave_test.how_many_sands_can_drop}"
cave_test.add_floor
cave_test.reset_sand
puts "Number of sands falling with floor (test): #{cave_test.how_many_sands_can_drop}"

cave_real = process_file("day14-input.txt")
puts "Number of sands before falling into void (real): #{cave_real.how_many_sands_can_drop}"
cave_real.add_floor
cave_real.reset_sand
puts "Number of sands falling with floor (test): #{cave_real.how_many_sands_can_drop}"