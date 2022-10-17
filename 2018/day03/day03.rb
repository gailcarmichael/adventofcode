class Fabric
  def initialize
    @fabric = Hash.new { |h, k| h[k] = [] }
  end

  def add_claim(id, start_x, start_y, width, height)
    for x in start_x..(start_x+width-1)
      for y in start_y..(start_y+height-1)
        @fabric[[x, y]] << id
      end
    end
  end

  def add_claim_from_string(line)
    m = /#([\d]+) @ ([\d]+),([\d]+): ([\d]+)x([\d]+)/.match(line)
    add_claim(m[1].to_i, m[2].to_i, m[3].to_i, m[4].to_i, m[5].to_i)
  end

  def inches_with_two_plus_claims
    @fabric.values.find_all {|ids| ids.length >= 2}.length
  end

  def find_non_overlapping_id
    ids_multiple = @fabric.reject{ |coord, ids| ids.length == 1 }.values.uniq.flatten
    ids_single = @fabric.reject{ |coord, ids| ids.length > 1 }.values.uniq.flatten
    (ids_single - ids_multiple)[0]
  end

  def to_s
    output = ""
    @fabric.each do |coord, ids|
      output += coord.to_s + ": \t" + ids.to_s + "\n"
    end
    output
  end
end

###

def process_file(filename, message)
  fabric = Fabric.new
  File.read(filename).strip.split("\n").each do |line|
    fabric.add_claim_from_string(line)
  end
  fabric.public_send(message)
end

puts "Test part 1: #{process_file("day03-input-test.txt", :inches_with_two_plus_claims)}"
puts "Real part 1: #{process_file("day03-input.txt", :inches_with_two_plus_claims)}"

puts "Test part 2: #{process_file("day03-input-test.txt", :find_non_overlapping_id)}"
puts "Real part 2: #{process_file("day03-input.txt", :find_non_overlapping_id)}"
