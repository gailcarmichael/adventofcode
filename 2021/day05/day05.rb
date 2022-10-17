class HydrothermalVentField
  
  def initialize()
    @field_grid = Hash.new(0)
    @max_x = @max_y = 0
  end

  def add_line(x1, y1, x2, y2, horz_only=true)
    # puts "(#{x1}, #{y1}) => (#{x2}, #{y2})"

    xs = ys = nil

    if x1 == x2 # vertical line
      xs = [x1] * ((y1-y2).abs + 1)
      if y1 < y2
        ys = (y1..y2).to_a
      else
        ys = (y2..y1).to_a
      end

    elsif y1 == y2 # horizontal line
      ys = [y1] * ((x1-x2).abs + 1)
      if x1 < x2
        xs = (x1..x2).to_a
      else
        xs = (x2..x1).to_a
      end

    else # diagonal line
      return if horz_only

      if x1 > x2
        xs = x1.downto(x2).to_a
      else
        xs = (x1..x2).to_a
      end

      if y1 > y2
        ys = y1.downto(y2).to_a
      else
        ys = (y1..y2).to_a
      end
    end

    xs.each_with_index do |x, index|
      y = ys[index]
      # puts "(#{x}, #{y})"
      @field_grid[[x,y]] += 1
      @max_x = [x, @max_x].max
      @max_y = [y, @max_y].max
      # puts self
    end
  end

  def how_many_points_have_overlap(min_lines_overlapping = 2)
    @field_grid.values.count{|line_count| line_count >= min_lines_overlapping}
  end

  def to_s
    s = ''
    (0..@max_y).each do |y|
      (0..@max_x).each do |x|
        if @field_grid[[x,y]] == 0
          s += '.'
        else
          s += "#{@field_grid[[x,y]]}"
        end
      end
      s += "\n"
    end
    s
  end

end

################################################################

def process_file(filename, horz_only=true)
  vent_field = HydrothermalVentField.new
  File.readlines(filename, chomp: true).each do |line|
    m = /(\d+),(\d+) -> (\d+),(\d+)/.match(line)
    vent_field.add_line(m[1].to_i, m[2].to_i, m[3].to_i, m[4].to_i, horz_only)
  end
  vent_field
end

################################################################

vent_field = process_file("day05-input-test.txt")
# puts vent_field
puts "Test number of points with two or more lines (horz only): #{vent_field.how_many_points_have_overlap}"

vent_field = process_file("day05-input.txt")
puts "Real number of points with two or more lines (horz only): #{vent_field.how_many_points_have_overlap}"

vent_field = process_file("day05-input-test.txt", false)
# puts vent_field
puts "Test number of points with two or more lines: #{vent_field.how_many_points_have_overlap}"

vent_field = process_file("day05-input.txt", false)
puts "Real number of points with two or more lines: #{vent_field.how_many_points_have_overlap}"