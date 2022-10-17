class Node
  attr_reader :id, :metadata, :children
  def initialize(id, metadata, children)
    @id = id
    @metadata = metadata
    @children = children
  end

  def to_s
    metadata_joined = ''
    metadata_joined = metadata.join(', ') if metadata

    "#{id} (#{metadata_joined}) -- #{children}"
  end
end

class Tree
  @@last_id = 0

  def initialize
    @nodes = {}
  end

  def to_s
    @nodes.values.join("\n")
  end

  def add_node(node)
    @nodes[node.id] = node
  end

  def add_nodes_from_data(data_list)
    @root_id = add_nodes_from_data_helper(data_list)
  end

  private def add_nodes_from_data_helper(data_list)
    @@last_id += 1

    id = @@last_id

    num_children = data_list.shift
    num_metadata = data_list.shift

    children = nil
    if (num_children > 0)
      children = []
      (1..num_children).each do |child_num|
        children << add_nodes_from_data_helper(data_list)
      end
    end

    metadata = data_list.slice!(0, num_metadata) if num_metadata > 0

    @nodes[id] = Node.new(id, metadata, children)

    id
  end

  def sum_of_all_metadata
    @nodes.values.reduce(0){|sum, node| sum + node.metadata.reduce(:+)}
  end

  def value_of_root
    value_of_node(@root_id)
  end

  private def value_of_node(id)
    value = 0

    children = @nodes[id].children
    metadata = @nodes[id].metadata

    if metadata && !metadata.empty?
      if children && !children.empty?
        # metadata interpreted as indexes into the children
        metadata.each do |child_index|
          if child_index <= children.length
            value += value_of_node(children[child_index-1])
          end
        end
      else
        # metadata interpreted as numbers to sum together
        value = metadata.reduce(:+)
      end
    end

    value
  end
end

###

def process_file(filename, message)
  tree = Tree.new
  tree.add_nodes_from_data(File.read(filename).strip.split(" ").map {|data| data.to_i})
  tree.public_send(message)
end

puts "Test part 1: #{process_file("day08-input-test.txt", :sum_of_all_metadata)}"
puts "Real part 1: #{process_file("day08-input.txt", :sum_of_all_metadata)}"

puts "Test part 2: #{process_file("day08-input-test.txt", :value_of_root)}"
puts "Real part 2: #{process_file("day08-input.txt", :value_of_root)}"
