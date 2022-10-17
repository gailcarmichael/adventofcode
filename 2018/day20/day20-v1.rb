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

  private

  def process_path(path_string, curr_x, curr_y, length_to_curr)
    # system "clear" or system "cls"
    # puts self.to_s
    # sleep(0.5)
    # puts path_string

    case path_string[0]
    when ''
    when nil
    when '('
      branches_and_after = extract_branches_plus_after(path_string)
      branches_and_after[0..-2].each do |branch|
        # process_path(branch + branches_and_after[-1], curr_x, curr_y, length_to_curr) #removed this
        process_path(branch, curr_x, curr_y, length_to_curr)
      end
      process_path(branches_and_after[-1], curr_x, curr_y, length_to_curr) # added this
    else
      result = process_single_char(path_string[0], curr_x, curr_y, length_to_curr)
      process_path(path_string[1..-1], result[:new_x], result[:new_y], result[:new_length])
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
    if @path_lengths[[curr_x, curr_y]] > 0
      @path_lengths[[curr_x, curr_y]] = [@path_lengths[[curr_x, curr_y]], length_to_curr].min
    else
      @path_lengths[[curr_x, curr_y]] = length_to_curr
    end

    reset_min_max(curr_x, curr_y)

    {new_x: curr_x, new_y: curr_y, new_length: length_to_curr}
  end

  def extract_branches_plus_after(path_string)
    return nil if path_string[0] != '('
    count = 0
    branch_string = ""
    branches = []

    path_string.split("").each_with_index do |char, index|
      if char == '('
        count += 1
        branch_string += char if count > 1
      elsif char == ')'
        count -= 1
        branch_string += char if count > 0
        branches << branch_string if count == 0
      elsif char == '|'
        if count == 1 # not inside other brackets
          branches << branch_string
          branch_string = ""
        else
          branch_string += char
        end
      else
        branch_string += char
      end
      
      if count == 0
        branches << branch_string
        branches << path_string[index+1..-1]
        return branches
      end
    end
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
end

#############

# process_regex('^ENWWW(NEEE|SSE(EE|N))$')
# process_regex('^ENNWSWW(NEWS|)SSSEEN(WNSE|)EE(SWEN|)NNN$')
# process_regex('^ESSWWN(E|NNENN(EESS(WNSE|)SSS|WWWSSSSE(SW|NNNE)))$')
# process_regex('^WSSEESWWWNW(S|NENNEEEENN(ESSSSW(NWSW|SSEN)|WSWWN(E|WWS(E|SS))))$')

process_regex(File.read("day20-input.txt").chomp)
