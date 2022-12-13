class HeightMap
    attr_reader :start
    attr_reader :end

    def initialize
        @heights = Hash.new
        @start = @end = nil
    end

    def set_height(row, col, height)
        if height == 'S'
            @start = [row,col]
            @heights[[row,col]] = 'a'
        elsif height == 'E'
            @end = [row,col]
            @heights[[row,col]] = 'z'
        else
            @heights[[row,col]] = height
        end
    end

    def distances_from_start
        distances_from(@start)
    end

    def distances_from(start_node)
        queue = [start_node]
        distances = Hash.new(-1)
        distances[start_node] = 0

        while current = queue.shift
            adjacent_nodes = [[current[0]-1, current[1]],
                              [current[0]+1, current[1]],
                              [current[0],   current[1]-1],
                              [current[0],   current[1]+1]]

            adjacent_nodes.each do |node|
                next if (node == nil || @heights[node] == nil)
                next if @heights[node].ord-@heights[current].ord > 1
                
                if distances[node] < 0
                    queue.push(node)
                    distances[node] = distances[current] + 1
                end
            end
        end

        distances
    end

    def shortest_distance_from_all_a
        distances = []
        @heights.filter{|k,v| v == 'a'}.each do |node, height|
            distances.push(distances_from(node)[self.end])
        end
        distances.filter{|d| d > 0}.min
    end
end


def process_file(filename)
    height_map = HeightMap.new
    File.read(filename).split("\n").each_with_index do |line, row|
        line.split("").each_with_index do |height, col|
            height_map.set_height(row, col, height)
        end
    end
    height_map
end

height_map_test = process_file("day12-input-test.txt")
puts "Steps from start to end (test) #{height_map_test.distances_from_start[height_map_test.end]}"
puts "Smallest distance from a to end (test) #{height_map_test.shortest_distance_from_all_a}"

height_map_real = process_file("day12-input.txt")
puts "Steps from start to end (real) #{height_map_real.distances_from_start[height_map_real.end]}"
puts "Smallest distance from a to end  (real) #{height_map_real.shortest_distance_from_all_a}"
