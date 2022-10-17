class Cave
  @@VALID_GEAR = {
    rocky:  [:climbing_gear, :torch],
    wet:    [:climbing_gear, :neither],
    narrow: [:torch, :neither]
  }

  @@FACTOR = 3

  def initialize(depth, target_x, target_y)
    @depth = depth
    @target_x = target_x
    @target_y = target_y

    @geologic_indexes = Hash.new(0)
    compute_geologic_indexes
  end

  def geologic_index(x,y)
    @geologic_index[[x,y]]
  end

  def erosion_level(x,y)
    (@geologic_indexes[[x,y]] + @depth) % 20183
  end

  def region_type(x,y)
    case (erosion_level(x,y) % 3)
    when 0
      :rocky
    when 1
      :wet
    when 2
      :narrow
    end
  end

  def risk_level_of_target_region
    total = 0
    0.upto(@target_y) do |y|
      0.upto(@target_x) do |x|
        total += case region_type(x,y)
        when :rocky
          0
        when :wet
          1
        when :narrow
          2
        end
      end
    end
    total
  end

  def to_s
    result = ""
    0.upto(@target_y*@@FACTOR) do |y|
      0.upto(@target_x*@@FACTOR) do |x|
        if (x == 0 && y == 0)
          result += "M"
        elsif (x == @target_x && y == @target_y)
          result += "T"
        else
          case region_type(x,y)
          when :rocky
            result += '.'
          when :wet
            result += "="
          when :narrow
            result += "|"
          end
        end

        result += "\n" if x == @target_x * @@FACTOR
      end
    end
    result
  end

  def shortest_minutes_to_target
    initial_info = [0,0,:torch]

    minutes = Hash.new(999999)
    minutes[initial_info] = 0

    q = []
    q.push(initial_info)

    while !q.empty?
      curr_info = q.min_by {|info| minutes[info]}
      q.delete(curr_info)
      
      adj_region_info = adjacent_regions(curr_info)
      next if !adj_region_info

      adj_region_info.each do |adj_info|

        new_minutes = minutes[curr_info]
        new_minutes += 1
        new_minutes += 7 if curr_info[2] != adj_info[2]

        if adj_info[0] == @target_x and adj_info[1] == @target_y and adj_info[2] != :torch
          new_minutes += 7
        end

        if minutes[adj_info] > new_minutes
          minutes[adj_info] = new_minutes
          q.push(adj_info)
        end
      end
    end
    # puts minutes_to_s(minutes)
    # p minutes
    
    minutes.select {|info,minutes| info[0] == @target_x and info[1] == @target_y}.values.min
  end

  private

  def minutes_to_s(minutes)
    result = ""
    @@FACTOR = 2
    0.upto(@target_y*@@FACTOR) do |y|
      0.upto(@target_x*@@FACTOR) do |x|
        if (x == 0 && y == 0)
          result += " M "
        elsif (x == @target_x && y == @target_y)
          result += " T "
        else
          min_minutes = minutes.select{|info| info[0]==x and info[1]==y}.values.min
          result += " #{min_minutes} "
        end

        result += "\n" if x == @target_x*@@FACTOR
      end
    end
    result
  end

  def compute_geologic_indexes
    0.upto(@target_y*@@FACTOR) do |y|
      0.upto(@target_x*@@FACTOR) do |x|
        next if x == 0 and y == 0
        next if x == @target_x and y == @target_y

        if y == 0
          @geologic_indexes[[x,y]] = x*16807
        elsif x == 0
          @geologic_indexes[[x,y]] = y*48271
        else
          @geologic_indexes[[x,y]] = erosion_level(x-1, y) * erosion_level(x, y-1)
        end
      end
    end
  end

  def info_options_for_region(x, y)
    @@VALID_GEAR[region_type(x,y)].map {|equipment| [x,y,equipment]}
  end

  def adjacent_regions(curr_info)
    x = curr_info[0]
    y = curr_info[1]
    equipment = curr_info[2]

    regions = []

    regions += info_options_for_region(x-1, y) if (x > 0)
    regions += info_options_for_region(x+1, y) if (x < @target_x*3)

    regions += info_options_for_region(x, y-1) if (y > 0)
    regions += info_options_for_region(x, y+1) if (y < @target_y*3)

    regions
  end

  def self.valid_for_region?(equipment, region)
    @@VALID_GEAR[region].include? equipment
  end
end

#################

# cave = Cave.new(510, 10, 10)
# puts cave.to_s
# puts "Risk level: #{cave.risk_level_of_target_region}"
# puts "Shortest minutes: #{cave.shortest_minutes_to_target}"

cave = Cave.new(3339, 10, 715)
puts cave.to_s
puts "Risk level: #{cave.risk_level_of_target_region}"
puts "Shortest minutes: #{cave.shortest_minutes_to_target}"
