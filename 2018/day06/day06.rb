require 'set'

class CoordinateChecker
  @@last_coord_id = 0

  def initialize
    @coords_by_id = {}
    @ids_by_coord = {}
  end

  def add_coordinate(x, y)
    @@last_coord_id += 1
    @coords_by_id[@@last_coord_id] = [x,y]
    @ids_by_coord[[x,y]] = @@last_coord_id
  end

  def to_s
    @coords_by_id.to_s
  end

  private def compute_coordinate_distances  
    @max_x = @coords_by_id.values.max{|c1, c2| c1[0] <=> c2[0]}[0]
    @max_y = @coords_by_id.values.max{|c1, c2| c1[1] <=> c2[1]}[1]

    distance_grid = Hash.new { |hash, key| hash[key] = Hash.new }

    @coords_by_id.each do |id, coord|
      (0..@max_x).each do |x|
        (0..@max_y).each do |y|
          distance_grid[[x,y]][id] = (coord[0]-x).abs + (coord[1]-y).abs
        end
      end
    end

    distance_grid
  end

  def closest_id(coord)
    @distance_grid ||= compute_coordinate_distances
    
    id_distances = @distance_grid[coord]

    return nil if !id_distances

    min_distance = id_distances.values.min
    all_mins = id_distances.select {|id, dist| dist == min_distance}

    return nil if all_mins.length > 1
 
    all_mins.keys[0]
  end

  def infinite_ids
    @distance_grid ||= compute_coordinate_distances

    ids = Set.new
    
    (0..@max_x).each {|x| ids.add(closest_id([x,0])) }
    (0..@max_x).each {|x| ids.add(closest_id([x,@max_y])) }

    (0..@max_y).each {|y| ids.add(closest_id([0,y])) }
    (0..@max_y).each {|y| ids.add(closest_id([@max_x,y])) }
    
    ids.delete(nil)
  end

  def size_of_largest_finite_area
    finite_ids = @coords_by_id.keys - infinite_ids.to_a
    area = Hash.new(0)

    (0..@max_x).each do |x|
      (0..@max_y).each do |y|
        id = closest_id([x,y])
        area[id] += 1 if finite_ids.include?(id)
      end
    end

    area.values.max
  end

  def size_of_region_near_many_ids(max_distance)
    @distance_grid ||= compute_coordinate_distances

    in_region = @distance_grid.select do |coord, id_distances|
      id_distances.values.reduce(:+) < max_distance
    end
    in_region.length
  end
end

###

def process_file(filename, message, arg=nil)
  checker = CoordinateChecker.new()
  File.read(filename).strip.split("\n").each do |line|
    line = line.split(", ")
    checker.add_coordinate(line[0].to_i, line[1].to_i)
  end

  if arg
    checker.public_send(message, arg)
  else
    checker.public_send(message)
  end
end

#puts "Test part 1: #{process_file("day06-input-test.txt", :size_of_largest_finite_area)}"
#puts "Real part 1: #{process_file("day06-input.txt", :size_of_largest_finite_area)}"

puts "Test part 2: #{process_file("day06-input-test.txt", :size_of_region_near_many_ids, 302)}"
puts "Real part 2: #{process_file("day06-input.txt", :size_of_region_near_many_ids, 10000)}"
