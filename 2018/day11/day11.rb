class FuelCells
  MIN_X = 1
  MAX_X = 300

  MIN_Y = 1
  MAX_Y = 300

  attr_reader :cells

  def initialize(serial_num)
    @serial_num = serial_num
    @cells = Hash.new(0)
    compute_power_levels
  end

  def compute_all_sizes_total_power
    convolved_cells = Hash.new(0)

    MIN_X.upto(MAX_X) {|x| convolved_cells[[x,MAX_Y,1]] = @cells[[x,MAX_Y]]}
    MIN_Y.upto(MAX_Y) {|y| convolved_cells[[MAX_X,y,1]] = @cells[[MAX_X,y]]}

    (MAX_X-1).downto(MIN_X) do |x|
      (MAX_Y-1).downto(MIN_Y) do |y|
        max_square_size = [MAX_X - x + 1, MAX_Y - y + 1].min

        row_sums = Hash.new(0)
        col_sums = Hash.new(0)

        convolved_cells[[x,y,1]] = @cells[[x,y]]
        
        2.upto(max_square_size) do |square_size|
          row_sums[square_size] = row_sums[square_size-1] + @cells[[x+square_size-1, y]]
          col_sums[square_size] = col_sums[square_size-1] + @cells[[x, y+square_size-1]]
        end

        2.upto(max_square_size) do |square_size|
          convolved_cells[[x,y,square_size]] = 
              @cells[[x,y]] + 
              row_sums[square_size] + 
              col_sums[square_size] + 
              convolved_cells[[x+1, y+1, square_size-1]]
        end
      end
    end
    convolved_cells
  end

  def compute_n_by_n_total_power(n=3)
    convolved_cells = Hash.new(0)
    (MIN_Y..MAX_Y-n).each do |y|
      (MIN_X..MAX_X-n).each do |x|
        (y..y+n-1).each do |inner_y|
          (x..x+n-1).each do |inner_x|
            convolved_cells[[x,y]] += @cells[[inner_x,inner_y]]
          end
        end
      end
    end
    convolved_cells
  end

  def coord_of_largest_square_of_power
    compute_n_by_n_total_power.max_by {|coord, total_power_level| total_power_level}[0]
  end

  def coord_of_largest_square_of_power_all_sizes
    compute_all_sizes_total_power.max_by {|coord, total_power_level| total_power_level}[0]
  end

  private

  def compute_power_levels
    (MIN_Y..MAX_Y).each do |y|
      (MIN_X..MAX_X).each do |x|
        @cells[[x,y]] = power_level_for(x,y)
      end
    end
  end

  def power_level_for(x, y)
    rack_id = x + 10
    power_level = rack_id * y + @serial_num
    power_level *= rack_id
    power_level = power_level / 100 % 10
    power_level -= 5
  end
end

###

# puts "Example power levels:"
# puts FuelCells.new(8).cells[[3,5]]
# puts FuelCells.new(57).cells[[122,79]]
# puts FuelCells.new(39).cells[[217,196]]
# puts FuelCells.new(71).cells[[101,153]]
# puts FuelCells.new(18).cells[[35, 45]]

# puts

# puts "Examples of largest 3x3 square:"
# p FuelCells.new(18).coord_of_largest_square_of_power
# p FuelCells.new(42).coord_of_largest_square_of_power

# puts

# puts "Real result part 1:"
# p FuelCells.new(8141).coord_of_largest_square_of_power

# puts

# puts "Examples for part 2:"
#p FuelCells.new(18).coord_of_largest_square_of_power_all_sizes

puts "Real result part 2:"
p FuelCells.new(8141).coord_of_largest_square_of_power_all_sizes
