class CollectionArea
  def initialize
    @acres = Hash.new(".")
    @max_x = 0
    @max_y = 0
  end

  def set_acre_type(x, y, character)
    if character == "|" or character == "\#" or character == "."
      @acres[[x,y]] = character
      @max_x = [@max_x, x].max
      @max_y = [@max_y, y].max
    else
      raise "set_acre_type invalid character #{character.inspect} at #{x},#{y}"
    end
  end

  def to_s
    result = ""
    (0..@max_y).each do |y|
      (0..@max_y).each do |x|
        result += @acres[[x,y]]
        result += "\n" if x == @max_x
      end
    end
    result
  end

  def new_area_after_one_minute
    new_area = CollectionArea.new

    @acres.each do |coord, character|
      new_area.set_acre_type(coord[0], coord[1], character) # stay the same by default
      count = adjacent_count(coord[0], coord[1])
      
      case character
      when "."
        new_area.set_acre_type(coord[0], coord[1], "|") if count["|"] >= 3
      when "|"
        new_area.set_acre_type(coord[0], coord[1], "\#") if count["\#"] >= 3
      when "\#"
        if !(count["\#"] >= 1 and count["|"] >= 1)
          new_area.set_acre_type(coord[0], coord[1], "\.")
        end
      else
        raise "new_area_after_one_minute invalid character #{character.inspect} at #{coord}"
      end
    end

    new_area
  end

  def total_resource_value
    trees = @acres.count {|coord, character| character == "|"}
    lumberyards = @acres.count {|coord, character| character == "\#"}
    trees*lumberyards
  end

  private

  def adjacent_count(x,y)
    count = Hash.new(0)

    (-1..1).each do |dy|
      (-1..1).each do |dx|
        next if dx==0 && dy==0
        count[@acres[[x+dx, y+dy]]] += 1
      end
    end

    count
  end
end

################

def process_file(filename, args=nil)
  collection_area = CollectionArea.new

  File.read(filename).strip.split("\n").each_with_index do |line, y|
    line.split("").each_with_index do |character, x|
      collection_area.set_acre_type(x,y,character)
    end
  end

  10.times {collection_area = collection_area.new_area_after_one_minute}

  puts "Resource value after 10 min: #{collection_area.total_resource_value}"

  # We need to get to 1,000,000,000 iterations
  # Values repeat after we hit 224436 for the first time on the 505th iteration (1-based).
  # There are 28 values that repeat.
  # (1000000000-505) % 28 = 19
  # So the (505 + 20)th value is the answer: 190164

  # puts collection_area.to_s

end

# process_file("day18-input-test.txt")
process_file("day18-input.txt")
