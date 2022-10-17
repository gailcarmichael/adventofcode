class GroundSlice
  def initialize
    @clay = Hash.new(false)
    @water_source = [500,0]
    
    @water_touched = Hash.new(false)
    @water_resting = Hash.new(false)
    
    @min_x = @min_y = 9999999
    @max_x = @max_y = 0
  end

  def add_clay(x, y)
    @clay[[x,y]] = true

    @min_x = [@min_x, x].min
    @max_x = [@max_x, x].max

    @min_y = [@min_y, y].min
    @max_y = [@max_y, y].max
  end

  def to_s
    result = ""
    (0..(@max_y+1)).each do |y|
      ((@min_x-1)..(@max_x+1)).each do |x|
        if [x,y] == @water_source
          result += "+"
        elsif @clay[[x,y]]
          result += "\#"
        elsif @water_resting[[x,y]]
          result += "~"
        elsif @water_touched[[x,y]]
          result += "|"
        else
          result += "."
        end
        result += "\n" if x == (@max_x+1)
      end
    end
    result
  end

  def simulate_water_falling # return number of blocks water has touched
    flow_down_one([@water_source[0], @water_source[1]+1])
  end

  def total_squares_water_reached
    total = 0
    
    @water_touched.each do |coord, touched|
      if touched && coord[1] >= @min_y && coord[1] <= @max_y
        total += 1
      end
    end
    @water_resting.each do |coord, resting| 
      if resting && !@water_touched[coord] && coord[1] >= @min_y && coord[1] <= @max_y
        total += 1
      end
    end
    
    total
  end

  def total_water_at_rest
    total = 0
    
    @water_resting.each do |coord, resting| 
      if resting && coord[1] >= @min_y && coord[1] <= @max_y
        total += 1
      end
    end
    
    total
  end

  private

  def flow_down_one(curr_coord) # return true if new layer has water resting
    under_curr_coord = [curr_coord[0], curr_coord[1]+1]
    if @clay[under_curr_coord] || @water_resting[under_curr_coord]
      return flow_down_one_handle_leftright(curr_coord)
    elsif @water_touched[under_curr_coord]
      @water_touched[curr_coord] = true
      return false
    elsif curr_coord[1] > @max_y
      return false
    else # room to move downward
      water_resting_under = flow_down_one(under_curr_coord)
      if water_resting_under || @water_resting[under_curr_coord]
        return flow_down_one_handle_leftright(curr_coord)
      else
        @water_touched[curr_coord] = true
        return false
      end
    end
  end

  def flow_down_one_handle_leftright(curr_coord) # return true if whole layer has water resting
    left_wall = flow_left_one([curr_coord[0]-1,curr_coord[1]])
    right_wall = flow_right_one([curr_coord[0]+1,curr_coord[1]], left_wall)
    
    if left_wall && right_wall
      @water_resting[curr_coord] = true
      return true
    else
      @water_touched[curr_coord] = true
      return false
    end
  end

  def flow_left_one(curr_coord) # return true if a wall was hit
    new_coord = [curr_coord[0]-1, curr_coord[1]]
    under_new_coord = [new_coord[0], new_coord[1]+1]

    if @clay[curr_coord]
      return true
    elsif @clay[new_coord]
      @water_touched[curr_coord] = true
      return true
    elsif !@clay[under_new_coord] && !@water_resting[under_new_coord]
      @water_touched[curr_coord] = true
      flow_down_one(new_coord)
      return false
    else
      left_wall = flow_left_one(new_coord)
      @water_touched[curr_coord] = true
      return left_wall
    end
  end

  def flow_right_one(curr_coord, left_wall) #return true if a wall was hit
    new_coord = [curr_coord[0]+1, curr_coord[1]]
    under_new_coord = [new_coord[0], new_coord[1]+1]
    
    if @clay[curr_coord]
      set_row_to_resting_water([curr_coord[0]-1, curr_coord[1]]) if left_wall
      return true
    elsif @clay[new_coord]
      @water_touched[curr_coord] = true
      set_row_to_resting_water(curr_coord) if left_wall
      return true
    elsif !@clay[under_new_coord] && !@water_resting[under_new_coord]
      @water_touched[curr_coord] = true
      flow_down_one(new_coord)
      return false
    else
      right_wall = flow_right_one(new_coord, left_wall)
      @water_touched[curr_coord] = true
      return right_wall
    end
  end

  def set_row_to_resting_water(curr_coord)
    while !@clay[curr_coord]
      @water_resting[curr_coord] = true
      @water_touched[curr_coord] = false
      curr_coord = [curr_coord[0]-1, curr_coord[1]]
    end    
  end
end

################

def process_file(filename, args=nil)
  slice = GroundSlice.new

  File.read(filename).strip.split("\n").each do |line|
    m = /x=([\d]+), y=([\d]+)\.\.([\d]+)/.match(line)
    if m
      x1 = x2 = m[1].to_i
      y1 = m[2].to_i
      y2 = m[3].to_i
    else
      m = /y=([\d]+), x=([\d]+)\.\.([\d]+)/.match(line)
      x1 = m[2].to_i
      x2 = m[3].to_i
      y1 = y2 = m[1].to_i
    end

    (y1..y2).each do |y|
      (x1..x2).each do |x|
        slice.add_clay(x, y)
      end
    end
  end

  slice.simulate_water_falling

  # puts slice.to_s
  puts "\nTotal squares water can reach: #{slice.total_squares_water_reached}\n"
  puts "\nTotal squares water at rest: #{slice.total_water_at_rest}\n"

end

# process_file("day17-input-test.txt")
process_file("day17-input.txt")
