class MemorySpace
  def initialize(max_x, max_y)
    @max_x = max_x
    @max_y = max_y

    @corrupted = Hash.new(false)
  end

  def to_s
    result = ""
    0.upto(@max_y).each do |y|
      0.upto(@max_x).each do |x|
        result += @corrupted[[x,y]] ? "#" : "."
      end
      result += "\n"
    end
    result
  end

  def byte_falls(coord)
    @corrupted[coord] = true
  end

  def bytes_falling(byte_list)
    byte_list.each {|b| byte_falls(b)}
  end

  def neighbours(coord)
    result = Array.new
    result.push([coord[0], coord[1]-1]) if !@corrupted[[coord[0], coord[1]-1]]
    result.push([coord[0], coord[1]+1]) if !@corrupted[[coord[0], coord[1]+1]]
    result.push([coord[0]-1, coord[1]]) if !@corrupted[[coord[0]-1, coord[1]]]
    result.push([coord[0]+1, coord[1]]) if !@corrupted[[coord[0]+1, coord[1]]]
    result.select{|coord| coord[0].between?(0,@max_x) && coord[1].between?(0,@max_y)}
  end

  def current_shortest_path(start_coord=nil, end_coord=nil)
    start_coord ||= [0,0]
    end_coord ||= [@max_x, @max_y]

    q = Queue.new
    explored = Hash.new(false)
    parents = Hash.new

    q.enq(start_coord)
    explored[start_coord] = true
    found_exit = false

    loop do
      break if q.empty?

      v = q.deq
      if end_coord == v
        found_exit = true
        break
      end

      neighbours(v).each do |w|
        if !(explored[w])
          explored[w] = true
          parents[w] = v
          q.enq(w)
        end
      end
    end

    return nil if !found_exit

    curr_coord = end_coord
    shortest_path = []
    loop do
      break if curr_coord == start_coord

      shortest_path.push(curr_coord)
      curr_coord = parents[curr_coord]
    end
    shortest_path
  end
end

##########################

def process_file(filename)
  File.read(filename).strip.split("\n").map do |line|
    line.split(",").map(&:to_i)
  end
end

######

puts
memory_space = MemorySpace.new(6, 6)
bytes = process_file("day18-input-test.txt")
memory_space.bytes_falling(bytes[0..11])
puts memory_space
puts "Min number of steps to reach exit (test): #{memory_space.current_shortest_path.length}"

puts
12.upto(bytes.length-1) do |byte_num|
  memory_space.byte_falls(bytes[byte_num])
  path = memory_space.current_shortest_path
  if path == nil
    puts "First coord of falling byte that causes no escape: #{bytes[byte_num]}"
    break
  end
end

######

puts
memory_space = MemorySpace.new(70, 70)
bytes = process_file("day18-input.txt")
memory_space.bytes_falling(bytes[0..1023])
puts memory_space
puts "Min number of steps to reach exit (real): #{memory_space.current_shortest_path.length}"

puts
1024.upto(bytes.length-1) do |byte_num|
  memory_space.byte_falls(bytes[byte_num])
  path = memory_space.current_shortest_path
  if path == nil
    puts "First coord of falling byte that causes no escape: #{bytes[byte_num]}"
    break
  end
end
