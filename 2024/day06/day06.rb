require 'set'

class Map

  @@MOVE_FORWARD = {'^' => [-1,0], '>' => [0,1], 'v' => [1,0], '<' => [0,-1]}
  @@TURN_RIGHT = {'^' => '>', '>' => 'v', 'v' => '<', '<' => '^'}

  def initialize()
    @map_grid = Hash.new(".")
    @map_grid_visited = Hash.new
    @max_row = @max_col = 0

    @guard_loc = [0,0]
    @guard_start_loc = @guard_loc.clone

    @guard_char = @guard_start_char = 'v'
  end

  def add(row, col, char)
    @map_grid[[row, col]] = char if char == '#'
    @map_grid.delete([row, col]) if char == "."

    if guard_char_list.include?(char)
      @guard_loc = [row,col]
      @guard_start_loc = @guard_loc.clone

      @guard_char = @guard_start_char = char
    end

    @max_row = [@max_row, row].max
    @max_col = [@max_col, col].max
  end

  def reset_guard_position(new_guard_loc, new_guard_char)
    @guard_loc = new_guard_loc
    @guard_char = new_guard_char
  end

  def to_s
    result = ""
    (0..@max_row).each do |row|
      row_string = ""
      (0..@max_col).each do |col|
        if @guard_loc == [row,col]
          row_string += @guard_char
        elsif @map_grid_visited[[row,col]] && !@map_grid_visited[[row,col]].empty?
          row_string += 'X'
        else
          row_string += @map_grid[[row,col]]
        end
      end
      result += row_string + "\n"
    end
    result
  end

  def num_spaces_guard_visited
    @map_grid_visited.keys.count
  end

  def guard_char_list
    @@TURN_RIGHT.keys
  end

  def move_forward(char, loc)
    [loc[0] + @@MOVE_FORWARD[char][0], loc[1] + @@MOVE_FORWARD[char][1]]
  end

  def turn_right(char)
    @@TURN_RIGHT[char]
  end

  def out_of_bounds?(loc)
    loc[0] < 0 || loc[0] > @max_row || loc[1] < 0 || loc[1] > @max_col
  end

  def on_an_obstacle?(loc)
    @map_grid[loc] == '#'
  end

  def in_a_loop?(loc)
    @map_grid_visited[loc] && @map_grid_visited[loc].include?(@guard_char)
  end

  def next_guard_move
    next_guard_loc = move_forward(@guard_char, @guard_loc)

    if out_of_bounds?(next_guard_loc)
      return :out_of_bounds
    elsif on_an_obstacle?(next_guard_loc)
      return :on_an_obstacle
    elsif in_a_loop?(next_guard_loc)
      return :found_loop
    end

    :move_forward
  end

  def map_guard_route(check_loops=false) # returns true if check_loops is true and there is a loop
    @map_grid_visited.clear
    reset_guard_position(@guard_start_loc, @guard_start_char)

    loop do
      @map_grid_visited[@guard_loc] ||= Set.new
      @map_grid_visited[@guard_loc].add(@guard_char)
      case next_guard_move
      when :out_of_bounds
        break
      when :on_an_obstacle
        @guard_char = turn_right(@guard_char)
      when :move_forward
        @guard_loc = move_forward(@guard_char, @guard_loc)
      when :found_loop
        return true
      end
    end

    false # never found a loop, or not checking for one
  end

  def count_num_obstacles_that_cause_loops
    map_guard_route
    initial_visited = @map_grid_visited.clone

    num_obstacles = 0
    initial_visited.each_key do |loc|
      next if loc == @guard_start_loc

      reset_guard_position(@guard_start_loc, @guard_char)
      add(loc[0], loc[1], '#')

      num_obstacles += 1 if map_guard_route(true)

      add(loc[0], loc[1], '.')
    end
    num_obstacles
  end
end

##########################

def process_file(filename)
  map = Map.new
  File.read(filename).strip.split("\n").each_with_index do |line, row|
    line.split("").each_with_index do |char, col|
      map.add(row,col,char) if char != "."
    end
  end
  map
end

puts
test_map = process_file("day06-input-test.txt")
test_map.map_guard_route
puts "Spaces guard visited: #{test_map.num_spaces_guard_visited}"
puts "Num obstacles that add loops: #{test_map.count_num_obstacles_that_cause_loops}"

puts
real_map = process_file("day06-input.txt")
real_map.map_guard_route
puts "Spaces guard visited: #{real_map.num_spaces_guard_visited}"
puts "Num obstacles that add loops: #{real_map.count_num_obstacles_that_cause_loops}"



####
# This is a brute-force way of checking for repetition after chopping off
# the front of the total path travelled one by one; it works, but is too
# slow for large input (keeping for interest's sake)
#
# shorter_path_list = path_list.clone
# 0.upto(path_list.length-1) do |loop_index|
#   path_string = shorter_path_list.map {|loc| "[#{loc[0]},#{loc[1]}]"}.join
#   path_string_doubled = path_string * 2
#
#   index = path_string_doubled[1..-1].index(path_string)
#   if (index != nil && index < path_string.length-1)
#     return true
#   end
#
#   shorter_path_list.shift
# end
