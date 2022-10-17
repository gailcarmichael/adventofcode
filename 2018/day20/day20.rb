class Map
  attr_reader :path_lengths
  def initialize
    @rooms_and_doors = Hash.new('#')
    @path_lengths = Hash.new(-1)

    @min_x = @min_y = 0
    @max_x = @max_y = 0
  end

  def to_s
    result = ""

    ((@min_y-1)..(@max_y+1)).each do |y|
      ((@min_x-1)..(@max_x+1)).each do |x|
        if x == 0 && y == 0
          result += "X"
        else
          result += @rooms_and_doors[[x,y]]
        end
        result += "\n" if x == @max_x + 1
      end
    end
    
    result
  end

  def lengths_to_s
    result = ""
    ((@min_y-1)..(@max_y+1)).each do |y|
      ((@min_x-1)..(@max_x+1)).each do |x|
        if x == 0 && y == 0
          result += "X"
        elsif @rooms_and_doors[[x,y]] == '.'
          result += @path_lengths[[x,y]].to_s
        else
          result += @rooms_and_doors[[x,y]]
        end
        result += "\n" if x == @max_x + 1
      end
    end
    result
  end

  def fill_map_with_regex(path_string)
    process_path(path_string, 0, 0 ,0)
  end

  def furthest_room_distance
    @path_lengths.values.max
  end

  def num_paths_at_least_1000
    @path_lengths.values.select{|length| length >= 1000}.count
  end

  private

  def process_path(path_string, curr_x, curr_y, length_to_curr)
    stack = []
    path_string.each_char do |char|
      case char
      when ''
        raise "Trying to process an empty path"
      when '('
        stack.push [curr_x,curr_y]
      when ')'
        stack.pop
      when '|'
        curr_x = stack[-1][0]
        curr_y = stack[-1][1]
        length_to_curr = @path_lengths[[curr_x,curr_y]]
      else
        result = process_single_char(char, curr_x, curr_y, length_to_curr)
        curr_x = result[:new_x]
        curr_y = result[:new_y]
        length_to_curr = result[:new_length]
      end
    end
  end

  def process_single_char(char, curr_x, curr_y, length_to_curr)
    raise "trying to process nil as a single char" if char == nil

    curr_x += dx_for_dir(char)
    curr_y += dy_for_dir(char)

    @rooms_and_doors[[curr_x, curr_y]] = door_for_dir(char)

    curr_x += dx_for_dir(char)
    curr_y += dy_for_dir(char)

    @rooms_and_doors[[curr_x, curr_y]] = '.'

    length_to_curr += 1
    if @path_lengths[[curr_x, curr_y]] != -1
      @path_lengths[[curr_x, curr_y]] = [@path_lengths[[curr_x, curr_y]], length_to_curr].min
    else
      @path_lengths[[curr_x, curr_y]] = length_to_curr
    end

    reset_min_max(curr_x, curr_y)

    {new_x: curr_x, new_y: curr_y, new_length: length_to_curr}
  end

  def door_for_dir(dir_char)
    if dir_char == 'N' or dir_char == 'S'
      '-'
    else
      '|'
    end
  end

  def dx_for_dir(dir_char)
    case dir_char
    when 'N'
      0
    when 'E'
      1
    when 'S'
      0
    when 'W'
      -1
    else
      raise "dx_for_dir invalid direction character #{dir_char.inspect}"
    end
  end

  def dy_for_dir(dir_char)
    case dir_char
    when 'N'
      -1
    when 'E'
      0
    when 'S'
      1
    when 'W'
      0
    else
      raise "dy_for_dir invalid direction character #{dir_char.inspect}"
    end
  end

  def reset_min_max(x, y)
    @min_x = [@min_x, x].min
    @max_x = [@max_x, x].max

    @min_y = [@min_y, y].min
    @max_y = [@max_y, y].max
  end
end


################

def process_regex(regex_string)

  map = Map.new
  map.fill_map_with_regex(regex_string[1..-2])

  puts map.to_s
  puts
  puts map.lengths_to_s
  puts

  puts "Furthest room distance: #{map.furthest_room_distance}"
  puts "Num paths at least 1000 long: #{map.num_paths_at_least_1000}"
end

#############

# process_regex('^ENWWW(NEEE|SSE(EE|N))$')
# process_regex('^ENNWSWW(NEWS|)SSSEEN(WNSE|)EE(SWEN|)NNN$')
# process_regex('^ESSWWN(E|NNENN(EESS(WNSE|)SSS|WWWSSSSE(SW|NNNE)))$')
# process_regex('^WSSEESWWWNW(S|NENNEEEENN(ESSSSW(NWSW|SSEN)|WSWWN(E|WWS(E|SS))))$')

process_regex(File.read("day20-input.txt").chomp)
