require 'set'

class Garden
  def initialize
    @plot_grid = Hash.new
    @max_row = @max_col = 0

    @ids_to_region = Hash.new{|h,k| h[k] = Array.new}
    @region_grid = Hash.new

    @fences = Hash.new
  end

  def to_s
    result = ""
    0.upto(@max_row) do |row|
      0.upto(@max_col) do |col|
        result += "[" + @region_grid[[row,col]] + "]"
      end
      result += "\n"
    end
    result
  end

  def add_plot(region, row, col)
    @plot_grid[[row,col]] = region
    @max_row = [@max_row, row].max
    @max_col = [@max_col, col].max
  end

  def organize_regions
    id_counts = Hash.new(0)
    @region_grid = @plot_grid.clone

    @plot_grid.each_pair do |loc, char|
      if @region_grid[loc] == char # aka not already visited and overwritten with an id
        id_counts[char] += 1
        new_id = char + id_counts[char].to_s

        # branch out from this plot to find reachable neighbour plots
        modify_grid_for_region(loc, char, new_id)
      end
    end
  end

  def modify_grid_for_region(curr_loc, plot_char, region_id)
    return if !curr_loc[0].between?(0,@max_row)
    return if !curr_loc[1].between?(0,@max_col)
    return if @plot_grid[curr_loc] != plot_char # different plot type
    return if @region_grid[curr_loc] == region_id # already visited/filled in

    @region_grid[curr_loc] = region_id
    @ids_to_region[region_id].push(curr_loc)

    modify_grid_for_region([curr_loc[0]-1, curr_loc[1]], plot_char, region_id)
    modify_grid_for_region([curr_loc[0]+1, curr_loc[1]], plot_char, region_id)
    modify_grid_for_region([curr_loc[0], curr_loc[1]-1], plot_char, region_id)
    modify_grid_for_region([curr_loc[0], curr_loc[1]+1], plot_char, region_id)
  end

  ############################

  def determine_fences
    @fences.clear
    @ids_to_region.each_pair do |region_id, loc_list|
      loc_list.each do |loc|
        @fences[loc] = Set.new
        @fences[loc].add(:above) if @region_grid[[loc[0]-1,loc[1]]]==nil || @region_grid[[loc[0]-1,loc[1]]] != region_id
        @fences[loc].add(:below) if @region_grid[[loc[0]+1,loc[1]]]==nil || @region_grid[[loc[0]+1,loc[1]]] != region_id
        @fences[loc].add(:left) if @region_grid[[loc[0],loc[1]-1]]==nil || @region_grid[[loc[0],loc[1]-1]] != region_id
        @fences[loc].add(:right) if @region_grid[[loc[0],loc[1]+1]]==nil || @region_grid[[loc[0],loc[1]+1]] != region_id
      end
    end
  end

  ############################

  def calculate_region_perimeter(region_id)
    determine_fences if @fences.empty?
    @ids_to_region[region_id].map do |loc|
      @fences[loc].length
    end.sum
  end

  def total_fencing_price
    @ids_to_region.keys.map do |region_id|
      @ids_to_region[region_id].length * calculate_region_perimeter(region_id)
    end.sum
  end

  ############################

  def num_adjacent_edge_parts(region_id, loc, fence_dir, visited)
    return 0 if @region_grid[loc] != region_id
    return 0 if @fences[loc]==nil || !@fences[loc].include?(fence_dir)
    return 0 if visited.include?([loc, fence_dir])

    num_adjacent = 1
    visited.push([loc, fence_dir])

    case fence_dir
    when :above, :below
      num_adjacent += num_adjacent_edge_parts(region_id, [loc[0],loc[1]-1],fence_dir,visited)
      num_adjacent += num_adjacent_edge_parts(region_id, [loc[0],loc[1]+1],fence_dir,visited)
    when :left, :right
      num_adjacent += num_adjacent_edge_parts(region_id, [loc[0]-1,loc[1]],fence_dir,visited)
      num_adjacent += num_adjacent_edge_parts(region_id, [loc[0]+1,loc[1]],fence_dir,visited)
    end

    num_adjacent
  end

  def calculate_num_sides(region_id)
    determine_fences if @fences.empty?

    visited = Array.new
    num_edges = @ids_to_region[region_id].map do |loc|
      if !@fences.has_key?(loc)
        0
      else
        @fences[loc].map do |fence_dir|
          if num_adjacent_edge_parts(region_id, loc, fence_dir, visited) > 0
            1
          else
            0
          end
        end.sum
      end
    end.sum

    num_edges
  end

  def total_fencing_price_part2
    @ids_to_region.keys.map do |region_id|
      @ids_to_region[region_id].length * calculate_num_sides(region_id)
    end.sum
  end
end

##########################

def process_file(filename)
  garden = Garden.new
  File.read(filename).strip.split("\n").each_with_index do |line, row|
    line.split("").each_with_index do |char, col|
      garden.add_plot(char, row, col)
    end
  end
  garden.organize_regions
  garden
end


puts
garden = process_file("day12-input-test.txt")
puts garden
puts "Total fencing price (test): #{garden.total_fencing_price}"
puts "Total fencing price part 2 (test): #{garden.total_fencing_price_part2}"


puts
garden = process_file("day12-input.txt")
puts "Total fencing price (real): #{garden.total_fencing_price}"
puts "Total fencing price part 2 (real): #{garden.total_fencing_price_part2}"
