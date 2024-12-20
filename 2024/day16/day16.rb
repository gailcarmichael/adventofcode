require 'Set'

class Maze

  attr_reader :start
  attr_reader :end

  def initialize
    @grid = Hash.new('.')
    @max_row = @max_col = 0
    @start = @end = [-1,-1]
  end

  def add_wall(row, col)
    @grid[[row,col]] = '#'
    @max_row = [@max_row, row].max
    @max_col = [@max_col, col].max
  end

  def set_start(row, col)
    @start = [row,col]
  end

  def set_end(row, col)
    @end = [row,col]
  end

  def neighbours_for(pos_and_dir)
    neighbour_infos = []
    pos = pos_and_dir[0..1]
    curr_dir = pos_and_dir[2]

    @@TURN_LEFT = {'>' => '^', '^' => '<', '<' => 'v', 'v' => '>'}
    @@TURN_RIGHT = {'>' => 'v', 'v' => '<', '<' => '^', '^' => '>'}
    @@GO_FORWARD = {'>' => [0,1], 'v' => [1,0], '<' => [0,-1], '^' => [-1,0]}

    if @grid[[pos[0] + @@GO_FORWARD[@@TURN_LEFT[curr_dir]][0],
              pos[1] + @@GO_FORWARD[@@TURN_LEFT[curr_dir]][1]]] != '#'
      neighbour_infos.push([[pos[0], pos[1], @@TURN_LEFT[curr_dir]], 1000])
    end

    if @grid[[pos[0] + @@GO_FORWARD[@@TURN_RIGHT[curr_dir]][0],
              pos[1] + @@GO_FORWARD[@@TURN_RIGHT[curr_dir]][1]]] != '#'
      neighbour_infos.push([[pos[0], pos[1], @@TURN_RIGHT[curr_dir]], 1000])
    end

    forward_pos = [pos[0] + @@GO_FORWARD[curr_dir][0], pos[1] + @@GO_FORWARD[curr_dir][1]]
    if @grid[forward_pos] != '#'
      neighbour_infos.push([[forward_pos[0], forward_pos[1], curr_dir], 1])
    end

    neighbour_infos
  end

  def shortest_path_dijkstra
    dist = Hash.new(Float::INFINITY)
    prev = Hash.new{|h,k| h[k] = Set.new}

    q = Set.new
    0.upto(@max_row) do |row|
      0.upto(@max_col) do |col|
        if @grid[[row,col]] == '.' # this includes start/end
          q.add([row, col, '<'])
          q.add([row, col, '>'])
          q.add([row, col, '^'])
          q.add([row, col, 'v'])
        end
      end
    end

    dist[[@start[0], @start[1], '>']] = 0

    while !q.empty?
      # slightly complicated way to get the min distance for something still in the queue
      dist_still_in_q = dist.select{|info| q.include?(info)}
      min_dist_value_still_in_q = dist_still_in_q.values.min
      info_with_min_dist = dist_still_in_q.select{|info, cost| cost == min_dist_value_still_in_q}
      info_with_min_dist = [info_with_min_dist.keys[0], min_dist_value_still_in_q]

      if info_with_min_dist[0][0..1] == @end
        break
      end

      q.delete(info_with_min_dist[0])

      neighbours_for(info_with_min_dist[0]).each do |neighbour_info|
        next if !q.include?(neighbour_info[0])

        alt = dist[info_with_min_dist[0]] + neighbour_info[1]

        if alt <= dist[neighbour_info[0]]
          dist[neighbour_info[0]] = alt

          prev[neighbour_info[0]].delete_if{|node_info| dist[node_info[0..2]] + node_info[-1] > alt}
          prev[neighbour_info[0]].add(info_with_min_dist[0] + [neighbour_info[1]])
        end
      end
    end

    [dist, prev]
  end

  def shortest_path_score
    results = shortest_path_dijkstra
    end_info_and_distances  = results[0].select{|info, d| info[0..1] == @end}
    end_info_and_distances.values.min
  end

  def num_tiles_in_a_best_path
    results = shortest_path_dijkstra

    end_info_and_distances = results[0].select{|info, d| info[0..1] == @end}
    min_end_dist = end_info_and_distances.values.min
    min_end_info_and_dist = end_info_and_distances.select{|info, d| d == min_end_dist}
    min_end_info = min_end_info_and_dist.keys[0] # assumes there is only one entry direction into end

    prev = results[1]

    visited_tiles = Set.new

    u = min_end_info
    visited_tiles.add(u[0..1])
    travel_best_paths(u, prev, visited_tiles, results[0])

    print_visited_tiles(visited_tiles)

    visited_tiles.size
  end

  def travel_best_paths(u, prev, visited_tiles, dist)
    if prev[u] || u == [@start[0], @start[1], '>']
      prev[u].each do |prev_u|
        visited_tiles.add(prev_u[0..1])
        travel_best_paths(prev_u[0..2], prev, visited_tiles, dist)
      end
    end
  end

  def print_visited_tiles(visited_tiles)
    result = ""

    num_visited = 0

    0.upto(@max_row) do |row|
      0.upto(@max_col) do |col|
        if visited_tiles.include?([row,col])
          result += 'O'
          num_visited += 1
        else
          result += @grid[[row,col]]
        end
      end
      result += "\n"
    end

    puts result
    puts num_visited
  end
end

##########################

def process_file(filename)
  maze = Maze.new
  File.read(filename).strip.split("\n").each_with_index do |line, row|
    line.split("").each_with_index do |char, col|
      case char
      when '#'
        maze.add_wall(row,col)
      when 'S'
        maze.set_start(row,col)
      when 'E'
        maze.set_end(row,col)
      end
    end
  end
  maze
end

puts
maze = process_file("day16-input-test.txt")
puts "Score for maze (test): #{maze.shortest_path_score}"
puts "Num tiles part of best paths (test): #{maze.num_tiles_in_a_best_path}"

puts
maze = process_file("day16-input.txt")
puts "Score for maze (real): #{maze.shortest_path_score}"
puts "Num tiles part of best paths (real): #{maze.num_tiles_in_a_best_path}"
