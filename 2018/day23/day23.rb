class Nanobot
  attr_reader :x, :y, :z, :radius

  def initialize(x, y, z, radius)
    @x = x
    @y = y
    @z = z
    @radius = radius
  end

  def distance_from(other_bot)
    (x - other_bot.x).abs + (y - other_bot.y).abs + (z - other_bot.z).abs
  end

  def in_range?(other_bot)
    distance_from(other_bot) <= radius
  end
end

################

def in_range_of_strongest_bot(bots)
  strongest = bots.max_by {|bot| bot.radius}
  p strongest
  bots.select {|bot| strongest.in_range?(bot)}
end

def process_file(filename, args=nil)
  bots = []
  File.read(filename).strip.split("\n").each do |line|
    m = /pos=<(-?[\d]+),(-?[\d]+),(-?[\d]+)>, r=([\d]+)/.match(line)
    bots << Nanobot.new(m[1].to_i, m[2].to_i, m[3].to_i, m[4].to_i)
  end

  puts "Num in range of strongest: #{in_range_of_strongest_bot(bots).length}"
end

# process_file("day23-input-test.txt")
process_file("day23-input.txt")
