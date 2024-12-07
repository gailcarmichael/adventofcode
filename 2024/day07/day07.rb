class OperatorTreeNode
  attr_reader :value
  attr_reader :operator
  attr_reader :children

  def initialize(value, operator)
    @value = value
    @operator = operator
    @children = Array.new
  end

  def add_child(node)
    @children.push(node)
  end

  def has_children?
    !@children.empty?
  end
end


class OperatorTree
  def initialize(value_list, use_concat=false)
    @root = build_tree(value_list[0], :none, value_list[1..-1], use_concat)
  end

  def collect_leaf_node_results(max_result, use_concat=false)
    leaf_results = Array.new
    collect_leaf_node_results_p(max_result, @root, @root.value, leaf_results, use_concat)
    leaf_results
  end

  private

  def build_tree(root_value, root_op, child_value_list, use_concat=false)
    root = OperatorTreeNode.new(root_value, root_op)

    if (!child_value_list.empty?)
      root.add_child(build_tree(child_value_list[0], :+, child_value_list[1..-1], use_concat))
      root.add_child(build_tree(child_value_list[0], :*, child_value_list[1..-1], use_concat))
      root.add_child(build_tree(child_value_list[0], :concat, child_value_list[1..-1], use_concat)) if use_concat
    end

    root
  end

  def collect_leaf_node_results_p(max_result, curr_node, result_so_far, results, use_concat)
    curr_result = result_so_far

    if curr_node.operator == :+
      curr_result += curr_node.value
    elsif curr_node.operator == :*
      curr_result *= curr_node.value
    elsif use_concat && curr_node.operator == :concat
      curr_result = (result_so_far.to_s + curr_node.value.to_s).to_i
    end


    if curr_result <= max_result # short-circuit if we are too large anyway
      if (curr_node.has_children?)
        curr_node.children.each {|child| collect_leaf_node_results_p(max_result, child, curr_result, results, use_concat)}
      else
        results.push(curr_result)
      end
    end
  end
end


def total_calibration_result(eq_list, use_concat=false)
  eq_list.filter do |eq|
    leaf_node_results = eq[:op_tree].collect_leaf_node_results(eq[:test_value], use_concat)
    leaf_node_results.include?(eq[:test_value])
  end.sum do |eq|
    eq[:test_value]
  end
end


#########################

def process_file(filename, use_concat=false)
  File.read(filename).strip.split("\n").map do |line|
    equation = Hash.new
    line_parts = line.split(": ")
    equation[:test_value] = line_parts[0].to_i
    equation[:op_tree] = OperatorTree.new(line_parts[1].strip.split(" ").map(&:to_i), use_concat)
    equation
  end
end

puts
eq_list = process_file("day07-input-test.txt")
puts "Calibration result (test): #{total_calibration_result(eq_list)}"
eq_list = process_file("day07-input-test.txt", true)
puts "Calibration result with concat (test): #{total_calibration_result(eq_list, true)}"

puts
eq_list = process_file("day07-input.txt")
puts "Calibration result (real): #{total_calibration_result(eq_list)}"
eq_list = process_file("day07-input.txt", true)
puts "Calibration result with concat (real): #{total_calibration_result(eq_list, true)}"
