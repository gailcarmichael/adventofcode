##########################
# Part 1

class Warehouse
  @@DELTAS = {'^' => [-1,0], '>' => [0,1], 'v' => [1,0], '<' => [0,-1]}

  attr_reader :wall_grid
  attr_reader :box_grid
  attr_reader :robot_pos
  attr_reader :max_row
  attr_reader :max_col

  def initialize
    @wall_grid = Hash.new('.')
    @box_grid = Hash.new(false)
    @robot_pos = [-1,-1]
    @max_row = @max_col = 0
  end

  def add_entity(pos, char)
    case char
    when '#'
      @wall_grid[pos] = char
    when 'O'
      @box_grid[pos] = true
    when '@'
      @robot_pos = pos
    end

    @max_row = [@max_row, pos[0]].max
    @max_col = [@max_col, pos[1]].max
  end

  def to_s
    result = ""

    0.upto(@max_row) do |row|
      0.upto(@max_col) do |col|
        pos = [row,col]
        if @box_grid[pos]
          result += "O"
        elsif @robot_pos == pos
          result += "@"
        else
          result += @wall_grid[pos]
        end
      end
      result += "\n"
    end

    result
  end

  def move_box(pos, dir)
    new_pos = [pos[0] + @@DELTAS[dir][0], pos[1] + @@DELTAS[dir][1]]

    if (@wall_grid[new_pos] == '#')
      return false
    elsif (@box_grid[new_pos])
      moved_box = move_box(new_pos, dir)
      if moved_box
        @box_grid[new_pos] = 'true'
        @box_grid[pos] = false
        return true
      else
        return false
      end
    else
      @box_grid[new_pos] = 'true'
      @box_grid[pos] = false
      return true
    end
  end

  def move_robot(dir)
    new_pos = [@robot_pos[0] + @@DELTAS[dir][0], @robot_pos[1] + @@DELTAS[dir][1]]

    if @wall_grid[new_pos] == '#'
      return false
    elsif @box_grid[new_pos]
      @robot_pos = new_pos if move_box(new_pos, dir)
    else
      @robot_pos = new_pos
      return true
    end
  end

  def sum_of_gps_coordinates
    @box_grid.keys.select{|pos| @box_grid[pos]}.map do |pos|
      100 * pos[0] + pos[1]
    end.sum
  end
end

##########################
# Part 2

class DoubleWideWarehouse < Warehouse

  def initialize(regular_warehouse)
    super()
    @max_row = regular_warehouse.max_row
    @max_col = regular_warehouse.max_col*2

    0.upto(regular_warehouse.max_row) do |row|
      0.upto(regular_warehouse.max_col) do |col|
        if regular_warehouse.box_grid[[row,col]]
          @box_grid[[row,col*2]] = '['
          @box_grid[[row,col*2+1]] = ']'
        elsif regular_warehouse.wall_grid[[row,col]] == '#'
          @wall_grid[[row,col*2]] = '#'
          @wall_grid[[row,col*2+1]] = '#'
        elsif regular_warehouse.robot_pos == [row,col]
          @robot_pos = [row,col*2]
        end
      end
    end
  end

  def to_s
    result = ""

    0.upto(@max_row) do |row|
      0.upto(@max_col) do |col|
        pos = [row,col]
        if @box_grid[pos]
          result += @box_grid[pos]
        elsif @robot_pos == pos
          result += "@"
        else
          result += @wall_grid[pos]
        end
      end
      result += "\n"
    end

    result
  end

  def will_box_hit_wall?(new_pos, dir)
    case dir
    when '<'
      @wall_grid[[new_pos[0], new_pos[1]]] == '#'
    when '>'
      @wall_grid[[new_pos[0], new_pos[1] + 1]] == '#'
    when '^', 'v'
      @wall_grid[[new_pos[0], new_pos[1]]] == '#' || @wall_grid[[new_pos[0], new_pos[1] + 1]] == '#'
    end
  end

  def will_box_hit_another_box?(new_pos, dir)
    case dir
    when '<'
      @box_grid[new_pos] == ']'
    when '>'
      @box_grid[[new_pos[0], new_pos[1]+1]] == '['
    when '^'
      ['[', ']'].include?(@box_grid[new_pos]) || ['[', ']'].include?(@box_grid[[new_pos[0], new_pos[1] + 1]])
    when 'v'
      ['[', ']'].include?(@box_grid[new_pos]) || ['[', ']'].include?(@box_grid[[new_pos[0], new_pos[1] + 1]])
    end
  end

  def boxes_touching_in_dir(new_pos, dir)
    boxes_hit = []
    if (dir == '^' || dir == 'v')
      boxes_hit.push([new_pos[0],new_pos[1]-1]) if @box_grid[[new_pos[0],new_pos[1]-1]] == '['
      boxes_hit.push(new_pos) if @box_grid[new_pos] == '['
      boxes_hit.push([new_pos[0],new_pos[1]+1]) if @box_grid[[new_pos[0],new_pos[1]+1]] == '['
    elsif (dir == '<')
      boxes_hit.push([new_pos[0],new_pos[1]-1]) if @box_grid[new_pos] == ']'
    elsif (dir == '>')
      boxes_hit.push([new_pos[0],new_pos[1]+1]) if @box_grid[[new_pos[0],new_pos[1]+1]] == '['
    end
    boxes_hit
  end

  def can_box_move_here?(new_pos, dir)
    return false if (will_box_hit_wall?(new_pos, dir))

    if (will_box_hit_another_box?(new_pos, dir))
      boxes_touching = boxes_touching_in_dir(new_pos, dir)

      boxes_touching_results = boxes_touching.map do |touching_pos|
        new_touching_pos = [touching_pos[0] + @@DELTAS[dir][0], touching_pos[1] + @@DELTAS[dir][1]]
        can_box_move_here?(new_touching_pos, dir)
      end
      return boxes_touching_results.all?
    else
      return true
    end
  end

  def move_box(pos, dir)
    pos = [pos[0], pos[1]-1] if @box_grid[pos] == ']'
    return false if @box_grid[pos] != '[' # not a box

    new_pos = [pos[0] + @@DELTAS[dir][0], pos[1] + @@DELTAS[dir][1]]

    if (can_box_move_here?(new_pos, dir))
      move_boxes_recursively(pos, new_pos, dir)
      return true
    else
      return false
    end
  end

  def move_boxes_recursively(pos, new_pos, dir)
    pos = [pos[0], pos[1]-1] if @box_grid[pos] == ']'
    return false if @box_grid[pos] != '[' # not a box

    # Move touching boxes
    boxes_touching_in_dir(new_pos, dir).each do |touching_box_pos|
      touching_box_new_pos = [touching_box_pos[0] + @@DELTAS[dir][0], touching_box_pos[1] + @@DELTAS[dir][1]]
      move_boxes_recursively(touching_box_pos, touching_box_new_pos, dir)
    end

    # Move this box
    @box_grid[[pos[0],pos[1]]] = false
    @box_grid[[pos[0],pos[1]+1]] = false
    @box_grid[new_pos] = '['
    @box_grid[[new_pos[0],new_pos[1]+1]] = ']'
  end

  def sum_of_gps_coordinates
    @box_grid.keys.select{|pos| @box_grid[pos] == '['}.map do |pos|
      100 * pos[0] + pos[1]
    end.sum
  end
end

##########################
###########################

def process_file(filename)
  warehouse = Warehouse.new
  movement_list = []

  file_parts = File.read(filename).strip.split("\n\n")

  file_parts[0].split("\n").each_with_index do |line, row|
    line.split("").each_with_index do |char, col|
      warehouse.add_entity([row,col], char)
    end
  end

  movement_list = file_parts[1].split("\n").map{|line| line.split("")}.flatten

  [warehouse, movement_list]
end

# puts
# warehouse, movement_list = process_file("day15-input-test.txt")
# puts warehouse
# movement_list.each do |dir|
#   warehouse.move_robot(dir)
#   puts "\nMove #{dir}:"
#   puts warehouse
# end

# puts
# warehouse, movement_list = process_file("day15-input-test2.txt")
# puts warehouse
# movement_list.each do |dir|
#   warehouse.move_robot(dir)
# end
# puts warehouse
# puts "Sum of GPS coordinates (test): #{warehouse.sum_of_gps_coordinates}"

# puts
# warehouse, movement_list = process_file("day15-input.txt")
# puts warehouse
# movement_list.each do |dir|
#   warehouse.move_robot(dir)
# end
# puts warehouse
# puts "Sum of GPS coordinates (real): #{warehouse.sum_of_gps_coordinates}"

# puts
# warehouse, movement_list = process_file("day15-input-test2.txt")
# warehouse = DoubleWideWarehouse.new(warehouse)
# puts warehouse
# movement_list[0..-1].each_with_index do |dir, i|
#   warehouse.move_robot(dir)
#   if i > 192
#     puts "\nMove #{dir}:"
#     puts warehouse
#   end
# end
# puts warehouse
# puts "Sum of GPS coordinates for double-wide warehouse (test): #{warehouse.sum_of_gps_coordinates}"

puts
warehouse, movement_list = process_file("day15-input.txt")
warehouse = DoubleWideWarehouse.new(warehouse)
movement_list.each do |dir|
  warehouse.move_robot(dir)
end
puts warehouse
puts "Sum of GPS coordinates for double-wide warehouse (real): #{warehouse.sum_of_gps_coordinates}"
