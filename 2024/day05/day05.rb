class Rules
  attr_accessor :nodes

  def initialize()
    @nodes = Hash.new{|h,k| h[k] = Array.new}
  end

  # I originally thought the ruleset was complete and consistent, but
  # that wasn't true; instead, you only want to use the rules with both
  # to/from values that are also in the update. To make use of code I've
  # already written, I am making it easy to create a rule subset here.
  # (This does make my solution running time slow but it saves time rewriting,
  # so...meh.)
  def copy_for_update(update)
    new_rules = Rules.new
    @nodes.each_pair do |from, to_list|
      if update.include?(from)
        to_list.each do |to|
          if update.include?(to)
            new_rules.add_rule(from, to)
          end
        end
      end
    end
    new_rules
  end

  def add_rule(from, to)
    @nodes[from].push(to)
  end

  def correct_order?(update)
    rule_subset = copy_for_update(update)

    update.each_cons(2) do |pair|
      return false if not rule_subset.nodes[pair[0]].include?(pair[1])
    end
  end

  def reorder_wrong_update(update)
    new_update = []
    copy_for_update(update).sorted_nodes().each do |page|
      if update.include?(page)
        new_update.push(page)
      end
    end
    new_update
  end

  def sorted_nodes
    root = @nodes.keys.filter {|page| not @nodes.values.flatten.include?(page)}[0]
    leaf = @nodes.values.flatten.filter {|page| @nodes[page].empty?}[0]

    @lp ||= longest_path(root, leaf)
    @lp
  end

  def longest_path(from, to, discovered=[])
    discovered = discovered.clone
    discovered.push(from)

    if from == to
      if discovered.size == @nodes.size
        return discovered
      else
        return []
      end
    end

    @nodes[from].each do |child|
      if !discovered.include?(child)
        path = longest_path(child, to, discovered)
        return path if not path.empty?
      end
    end
    []
  end

  def middle_pages_added(updates)
    updates.filter{|update| correct_order?(update)}.sum do |update|
      update[update.length/2]
    end
  end

  def incorrect_middle_pages_added(updates)
    updates.filter{|update| !correct_order?(update)}.sum do |update|
      reorder_wrong_update(update)[update.length/2]
    end
  end
end

def process_file(filename)
  puzzle_data = {}
  input_parts = File.read(filename).strip.split("\n\n")

  rules = Rules.new
  puzzle_data[:rules] = input_parts[0].split("\n").map do |line|
    rule_parts = line.strip.split("|").map(&:to_i)
    rules.add_rule(rule_parts[0], rule_parts[1])
  end
  puzzle_data[:rules] = rules

  puzzle_data[:updates] = (input_parts[1].split("\n").map do |line|
    line.split(",").map(&:to_i)
  end)

  puzzle_data
end

puts
test_data = process_file("day05-input-test.txt")
puts "Correct updates sum (test): #{test_data[:rules].middle_pages_added(test_data[:updates])}"
puts "Incorrect updates sum (test): #{test_data[:rules].incorrect_middle_pages_added(test_data[:updates])}"

puts
real_data = process_file("day05-input.txt")
puts "Correct updates sum (real): #{real_data[:rules].middle_pages_added(real_data[:updates])}"
puts "Incorrect updates sum (test): #{real_data[:rules].incorrect_middle_pages_added(real_data[:updates])}"
