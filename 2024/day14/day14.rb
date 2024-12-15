class Robot
  attr_reader :pos
  attr_reader :vel

  def initialize(pos, vel)
    @pos = pos
    @vel = vel
  end

  def move(max_x, max_y)
    @pos[0] = (@pos[0] + @vel[0]) % (max_x+1)
    @pos[1] = (@pos[1] + @vel[1]) % (max_y+1)
  end

  def quadrant(max_x, max_y)
    mid_x = (max_x/2).floor
    mid_y = (max_y/2).floor

    if pos[0] < mid_x && pos[1] < mid_y
      0
    elsif pos[0] > mid_x && pos[1] < mid_y
      1
    elsif pos[0] < mid_x && pos[1] > mid_y
      2
    elsif pos[0] > mid_x && pos[1] > mid_y
      3
    end
  end
end

class TileFloor
  def initialize(width,height)
    @max_x = width-1
    @max_y = height-1
    @robots = Array.new
    @floor_grid = Hash.new{|h,k| h[k] = Array.new}
  end

  def add_robot(pos, vel)
    new_robot = Robot.new(pos, vel)
    @robots.push(new_robot)
    @floor_grid[pos].push(new_robot)
  end

  def to_s
    result = ""
    0.upto(@max_y).each do |y|
      0.upto(@max_x).each do |x|
        if @floor_grid[[x,y]].length > 0
          result += @floor_grid[[x,y]].length.to_s
        else
          result += "."
        end
      end
      result += "\n"
    end
    result
  end

  def move_all_robots_once
    @robots.each do |robot|
      @floor_grid[robot.pos].delete(robot)
      robot.move(@max_x, @max_y)
      @floor_grid[robot.pos].push(robot)
    end
  end

  def safety_after_time(seconds=100)
    1.upto(seconds) { move_all_robots_once }

    quadrant_count = [0,0,0,0]
    @robots.each do |robot|
      quadrant = robot.quadrant(@max_x, @max_y)
      next if !quadrant
      quadrant_count[quadrant] += 1
    end

    quadrant_count.inject(:*)
  end

  def some_robots_in_a_vertical_line?
    x_values = Hash.new(0)
    @robots.each {|r| x_values[r.pos[0]] += 1}
    x_values.values.any?{|count| count >= 15}
  end
end

###################################

def process_file(filename, width=101, height=103)
  floor = TileFloor.new(width, height)
  File.read(filename).strip.split("\n").each do |line|
    matchData = /p=(-?\d+,-?\d+) v=(-?\d+,-?\d+)/.match(line)
    pos = matchData[1].split(",").map(&:to_i)
    vel = matchData[2].split(",").map(&:to_i)

    floor.add_robot(pos, vel)
  end
  floor
end

puts
floor = process_file("day14-input-test.txt", 11, 7)
puts "Safety factor after 100 seconds (test): #{floor.safety_after_time(100)}"

puts
floor = process_file("day14-input.txt")
puts "Safety factor after 100 seconds (real): #{floor.safety_after_time(100)}"

####
# Part 2 (largely done through experimentation)

puts
floor = process_file("day14-input.txt")
time_count = 0
loop do
  loop do
    floor.move_all_robots_once
    time_count += 1
    if time_count >= 7000 && floor.some_robots_in_a_vertical_line?
      break
    end
    # p time_count
  end
  system "clear" or system "cls"
  puts floor
  puts time_count
  STDOUT.flush
  puts "press a key"
  gets.chomp
  floor.move_all_robots_once
  time_count += 1
end
