class Unit
  attr_reader :x, :y
  attr_accessor :hit_points
  attr_accessor :attack_power
  attr_accessor :dead

  def initialize(x,y)
    @x = x
    @y = y
    @hit_points = 200
    @attack_power = 3
    @dead = false
  end

  def move(dx, dy)
    move_to([@x = dx, @y + dy])
  end

  def move_to(coord)
    @x = coord[0]
    @y = coord[1]
  end

  def adjacent?(other_x, other_y)
    if @y == other_y
      @x == other_x - 1 || @x == other_x + 1
    elsif @x == other_x
      @y == other_y - 1 || @y == other_y + 1
    else
      false
    end
  end

  def attacked_by(attacker_unit)
    @hit_points -= attacker_unit.attack_power
    if @hit_points <= 0
      @dead = true
    end
  end

  def dead?
    @dead
  end

  def in_range?(other_unit)
    adjacent?(other_unit.x, other_unit.y)
  end
end

class Elf < Unit
  def enemy?(other_unit)
    other_unit.kind_of?(Goblin)
  end

  def to_s
    'E'
  end
end

class Goblin < Unit
  def enemy?(other_unit)
    other_unit.kind_of?(Elf)
  end

  def to_s
    'G'
  end
end

###

class Map
  attr_reader :map_grid, :units_list

  def initialize
    @map_grid = Hash.new('.')
    @units_grid = {}
    @units_list = []

    @max_x = @max_y = 0
  end

  def add_feature(x, y, character)
    case character
    when '#'
      @map_grid[[x,y]] = character
    when '.'
      @map_grid[[x,y]] = character
    when 'E'
      elf = Elf.new(x,y)
      @units_grid[[x,y]] = elf
      @units_list << elf
      @map_grid[[x,y]] = '.'
    when 'G'
      goblin = Goblin.new(x,y)
      @units_grid[[x,y]] = goblin
      @units_list << goblin
      @map_grid[[x,y]] = '.'
    #when ' '
    else
      raise "Trying to add an invalid feature #{character.inspect} at #{x},#{y}"
    end

    @max_x = [@max_x, x].max
    @max_y = [@max_y, y].max
  end

  def space_free?(coord)
    @map_grid[coord] == '.' && (@units_grid[coord] == nil || @units_grid[coord].dead?)
  end

  def enemy_units_remaining?(unit)
    !@units_list.select {|possible_target| unit.enemy?(possible_target) && !possible_target.dead?}.empty?
  end

  def move_unit_to(unit, coord)
    return if unit.dead?
    @units_grid.delete([unit.x, unit.y])
    unit.move_to(coord)
    @units_grid[coord] = unit
  end

  def sort_units_list!
    @units_list = Map.sort_units(@units_list)
  end

  def self.sort_units(units_list)
    units_list.sort! do |unit1, unit2|
      if unit1.y < unit2.y
        -1
      elsif unit1.y == unit2.y
        unit1.x <=> unit2.x
      else
        1
      end
    end
  end

  def coords_in_range_for(unit) # note: does not check if spaces in range are empty
    return if unit.dead?
    coords = []
    @units_list.each do |target|
      next if target.dead?
      if unit.enemy?(target)
        new_coords = [[target.x-1, target.y], [target.x+1, target.y],
                      [target.x, target.y-1], [target.x, target.y+1]]

        new_coords.each do |coord|
          coords << coord
        end
      end
    end
    Map.sort_coords_reading_order(coords)
  end

  def targets_adjacent_to(unit)
    adjacent = []
    @units_list.each do |possible_target|
      next if possible_target.dead?
      if unit.enemy?(possible_target) && unit.in_range?(possible_target)
        adjacent << possible_target
      end
    end
    adjacent
  end

  def shortest_path(from_coord, to_coord)
    visited = Hash.new(false)
    visited[from_coord] = true

    dist = Hash.new(:infinity)
    dist[from_coord] = 0

    predecessor = Hash.new(nil)

    q = []
    q.push(from_coord)

    found_to_coord = false
    while !q.empty? && !found_to_coord
      coord = q.shift
      
      adj_coords = [[coord[0],   coord[1]-1],
                    [coord[0]-1, coord[1]],
                    [coord[0]+1, coord[1]],
                    [coord[0],   coord[1]+1]]

      adj_coords.each do |adj_coord|
        next if visited[adj_coord]
        next if !space_free?(adj_coord)

        visited[adj_coord] = true
        dist[adj_coord] = dist[coord] + 1
        predecessor[adj_coord] = coord
        q.push(adj_coord)

        if adj_coord == to_coord
          found_to_coord = true
          break
        end
      end
    end

    if found_to_coord
      path = [to_coord]
      to_crawl = to_coord
      while predecessor[to_crawl]
        path.unshift(predecessor[to_crawl])
        to_crawl = predecessor[to_crawl]
      end
      return path
    else
      return nil
    end
  end

  def to_s
    result = ''
    @map_grid.each do |coord, character|
      if @units_grid[coord] && !@units_grid[coord].dead?
        result += @units_grid[coord].to_s
      else
        result += @map_grid[coord]
      end
      result += "\n" if coord[0] == @max_x
    end
    result
  end

  def self.sort_coords_reading_order(list_of_coords)
    list_of_coords.sort do |coord1, coord2|
      if coord1[1] < coord2[1]
        -1
      elsif coord1[1] == coord2[1]
        coord1[0] <=> coord2[0]
      else
        1
      end
    end
  end
end

###

class Combat
  attr_reader :map

  def initialize(map)
    @map = map
  end

  def do_round
    @round_num ||= 0
    @round_num += 1

    puts "---\nRound #{@round_num}!\n---"

    @map.sort_units_list! # put units into reading order

    @map.units_list.each do |unit|
      next if unit.dead?
      
      result = move_unit(unit)
      #puts "Move result: #{result}"
      return result if result == :no_targets_left
      next if result == :no_squares_in_range || result == :no_squares_in_range_reachable
      
      result = attack_with(unit)
      # puts "Attack result: #{result}"
      return result if result == :no_targets_left
      next if result == :no_targets_in_range
    end
  end

  def move_unit(unit)
    return :no_targets_left if !@map.enemy_units_remaining?(unit)

    in_range_list = @map.coords_in_range_for(unit)
    return :already_in_range if in_range_list.include?([unit.x, unit.y])

    in_range_list = in_range_list.select{|coord| map.space_free?(coord)}
    return :no_squares_in_range if in_range_list.empty?

    shortest_paths = in_range_list.map {|in_range_coord| @map.shortest_path([unit.x, unit.y], in_range_coord)}
    shortest_paths = shortest_paths.reject {|path| path == nil}
    return :no_squares_in_range_reachable if shortest_paths.empty?

    min_shortest_path_length = shortest_paths.min {|path1,path2| path1.length <=> path2.length}.length
    min_shortest_paths = shortest_paths.select {|path| path.length == min_shortest_path_length}

    possible_squares = []
    min_shortest_paths.each do |path|
      possible_squares << path[-1]
    end
    possible_squares = Map.sort_coords_reading_order(possible_squares)
    chosen_path = min_shortest_paths.select {|path| path[-1] == possible_squares[0]}[0]

    map.move_unit_to(unit,chosen_path[1])
    return :successfully_moved
  end

  def attack_with(unit)
    return :no_targets_left if !@map.enemy_units_remaining?(unit)

    adjacent = @map.targets_adjacent_to(unit)
    if adjacent.empty?
      return :no_targets_in_range
    else
      min = adjacent.min_by {|unit| unit.hit_points}
      adjacent = adjacent.select {|unit| unit.hit_points == min.hit_points}
      adjacent = Map.sort_units(adjacent)

      adjacent[0].attacked_by(unit)
      return :successfully_attacked
    end
  end

  def outcome
    sum_hit_points = @map.units_list.reduce(0) do |sum, unit|
      if unit.dead?
        sum
      else
        sum + unit.hit_points
      end
    end
    sum_hit_points * (@round_num-1)
  end

  def all_elves_alive?
    @map.units_list.none? {|unit| unit.kind_of?(Elf) && unit.dead?}
  end
end

################

def process_file(filename, args=nil)

  3.upto(100) do |new_attack_power|
    map = Map.new

    File.read(filename).chomp.split("\n").each_with_index do |line, y|
      line.strip.split('').each_with_index do |character, x|
        map.add_feature(x, y, character)
      end
    end

    map.units_list.each do |unit|
      if unit.kind_of?(Elf)
        unit.attack_power = new_attack_power
      end
    end

    combat = Combat.new(map)

    # puts map.to_s

    loop do
      # puts
      result = combat.do_round
      # puts map.to_s
      # map.units_list.each {|unit| p unit}
      # puts

      break if result == :no_targets_left
    end

    puts "\nOutcome: #{combat.outcome}"
    puts "All elves alive: #{combat.all_elves_alive?}"

    break if combat.all_elves_alive?
  end
end

#process_file("day15-input-test3.txt")
process_file("day15-input.txt")
