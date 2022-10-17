class Message
  attr_reader :points

  def initialize
    @points = []
  end

  def add_point(x, y, dx, dy)
    @points << [x, y, dx, dy]
  end

  def bounding_box
    points_hash = self.points_hash

    min_x = points_hash.keys.min_by {|point| point[0]}[0]
    max_x = points_hash.keys.max_by {|point| point[0]}[0]

    min_y = points_hash.keys.min_by {|point| point[1]}[1]
    max_y = points_hash.keys.max_by {|point| point[1]}[1]

    {min_x: min_x, min_y: min_y, max_x: max_x, max_y: max_y}
  end

  def move_points
    new_points = {}
    @points.each do |point_array|
      point_array[0] = point_array[0] + point_array[2]
      point_array[1] = point_array[1] + point_array[3]
    end
  end

  def move_until_bounding_box_small
    time = 0
    loop do
      move_points
      time += 1
      bounding_box = self.bounding_box
      x_diff = (bounding_box[:min_x] - bounding_box[:max_x]).abs
      y_diff = (bounding_box[:min_y] - bounding_box[:max_y]).abs
      break if x_diff < 100 and y_diff < 100
    end
    time
  end

  def points_hash
    h = {}
    @points.each do |point_array|
      h[[point_array[0], point_array[1]]] = true
    end
    h
  end

  def to_s
    points_hash = self.points_hash
    bounding_box = self.bounding_box

    result = ''
    (bounding_box[:min_y]..bounding_box[:max_y]).each do |y|
      (bounding_box[:min_x]..bounding_box[:max_x]).each do |x|
        if (points_hash[[x,y]])
          result += "\#"
        else
          result += "."
        end
      end
      result += "\n"
    end
    result
  end

end

###

def process_file(filename)
  sky_message = Message.new
  File.read(filename).strip.split("\n").each do |line|
    m = /position=<(\s*\-?[\d]+),\s*(\-?[\d]+)> velocity=<(\s*\-?[\d]+),\s*(\-?[\d]+)>/.match(line)
    sky_message.add_point(m[1].to_i, m[2].to_i, m[3].to_i, m[4].to_i) if m
  end
  
  first_time = sky_message.move_until_bounding_box_small
  (0..3).each do |time|
    system "clear" or system "cls"
    puts sky_message.to_s
    puts (time + first_time)
    STDOUT.flush
    sleep(1)
    sky_message.move_points
  end
end

process_file("day10-input-test.txt")
#process_file("day10-input.txt")
