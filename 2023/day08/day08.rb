class Node
  attr_reader :name, :left_name, :right_name

  def initialize(name, left_name, right_name)
    @name = name
    @left_name = left_name
    @right_name = right_name
  end
end


class Network
  def initialize
    @nodes = Hash.new
  end

  def add_node(name, left, right)
    @nodes[name] = Node.new(name, left, right)
  end

  ###

  def steps_to_follow_sequence(sequence, start_name='AAA', ghost_style=false)
    curr_node_name = start_name
    curr_sequence_index = -1
    num_steps = 0

    found_end = false
    while (!found_end)
      num_steps += 1
      curr_sequence_index = (curr_sequence_index + 1) % sequence.size
      if (sequence[curr_sequence_index] == "L")
        curr_node_name = @nodes[curr_node_name].left_name
      else
        curr_node_name = @nodes[curr_node_name].right_name
      end
      found_end = ghost_style ? curr_node_name[-1] == 'Z' : curr_node_name == 'ZZZ'
    end
    num_steps
  end

  ###

  def steps_to_follow_ghost_walk(sequence)
    start_nodes = @nodes.filter {|name, node| name[-1] == "A"}
    steps_to_end_ghost_style = start_nodes.keys.map do |node_name|
      steps_to_follow_sequence(sequence, node_name, true)
    end

    steps_to_end_ghost_style.reduce(1, :lcm)
  end
end

####

def process_file(filename)
  lines = File.read(filename).strip.split("\n")

  network = Network.new
  lines[2..].each do |line|
    match_data = /([1-9A-Z]{3}) = \(([1-9A-Z]{3}), ([1-9A-Z]{3})\)/.match(line)
    network.add_node(match_data[1], match_data[2], match_data[3])
  end

  [lines[0].split(""), network]
end

####

sequence, network = process_file("day08-input-test.txt")
puts "Steps required to go from AAA to ZZZ (test 1): #{network.steps_to_follow_sequence(sequence)}"

sequence, network = process_file("day08-input-test-2.txt")
puts "Steps required to go from AAA to ZZZ (test 2): #{network.steps_to_follow_sequence(sequence)}"

sequence, network = process_file("day08-input.txt")
puts "Steps required to go from AAA to ZZZ (real): #{network.steps_to_follow_sequence(sequence)}"

puts

sequence, network = process_file("day08-input-test-3.txt")
puts "Steps required for ghost walk (test 3): #{network.steps_to_follow_ghost_walk(sequence)}"

sequence, network = process_file("day08-input.txt")
puts "Steps required for ghost walk (real): #{network.steps_to_follow_ghost_walk(sequence)}"
