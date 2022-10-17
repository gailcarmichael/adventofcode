class HeightMap
  attr_reader :low_points

  def initialize
    @heights = Hash.new(9999)
    @low_points = Hash.new(false)
    @max_x = 0
    @max_y = 0
  end

  def add_height_value(x, y, value)
    @heights[[x,y]] = value
    @max_x = [@max_x, x].max
    @max_y = [@max_y, y].max
  end

  def mark_low_points
    @heights.keys.each do |coord|
      x = coord[0]
      y = coord[1]

      @low_points[[x,y]] = 
        ((@heights[[x,y]] < @heights[[x, y-1]]) &&
         (@heights[[x,y]] < @heights[[x-1, y]]) &&
         (@heights[[x,y]] < @heights[[x+1, y]]) &&
         (@heights[[x,y]] < @heights[[x, y+1]]))
    end
  end

  def risk_level(x,y)
    if @heights[[x,y]] < 9999
      @heights[[x,y]] + 1
    else
      1
    end
  end

  def sum_of_risk_level_low_points
    @heights.keys.reduce(0) do |sum, coord|
      if @low_points[coord]
        sum + risk_level(coord[0], coord[1])
      else
        sum       
      end
    end
  end

  def size_of_basin_from(x, y, visited)
    return 0 if x < 0 or x > @max_x or y < 0 or y > @max_y
    return 0 if @heights[[x,y]] == 9
    return 0 if visited.include?([x,y])
    
    visited.push([x,y])

    1 + size_of_basin_from(x-1, y, visited) + 
        size_of_basin_from(x+1, y, visited) +
        size_of_basin_from(x, y-1, visited) +
        size_of_basin_from(x, y+1, visited)
  end

  def size_of_basin_from_low_point(x, y)
    if not @low_points[[x,y]]
      puts "(#{x}, #{y}) is not a low point."
      return -1
    end

    size_of_basin_from(x, y, Array.new)
  end

  def product_three_largest_basin_sizes
    basin_sizes = @low_points.keys.filter{|coord| @low_points[coord]}.map do |coord|
      size_of_basin_from_low_point(coord[0], coord[1])
    end.sort
    basin_sizes[-1] * basin_sizes[-2] * basin_sizes[-3]
  end

  def to_s
    result = ""
    (0..@max_y).each do |y|
      (0..@max_x).each do |x|
        result += @heights[[x,y]].to_s
      end
      result += "\n"
    end
    result
  end
end


################################################################

def process_file(filename)
  height_map = HeightMap.new
  File.read(filename, chomp: true).split("\n").each_with_index do |line, y|
    line.split('').map(&:to_i).each_with_index do |height, x|
      height_map.add_height_value(x, y, height)
    end
  end
  height_map
end

################################################################

puts "\nTest:"
height_map = process_file("day09-input-test.txt")
height_map.mark_low_points
puts height_map
puts "Sum of low point risk levels: #{height_map.sum_of_risk_level_low_points}"
puts "Size of basin from 2,2: #{height_map.size_of_basin_from_low_point(2,2)}"
puts "Product of three largest basin sizes: #{height_map.product_three_largest_basin_sizes}"

puts "\n\nReal:"
height_map = process_file("day09-input.txt")
height_map.mark_low_points
puts "Sum of low point risk levels: #{height_map.sum_of_risk_level_low_points}"
puts "Product of three largest basin sizes: #{height_map.product_three_largest_basin_sizes}"