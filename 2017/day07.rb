input = File.read("day07-input.txt").strip

structure = Hash.new
weights = Hash.new
isAChild = Hash.new(false)


# Process the input and save into useful structures
input.split("\n").each do |line|

  matchData = /(\w*) \((\d+)\)(?: * -> (.+))?/.match(line)
  
  parent = matchData[1]
  weight = matchData[2]
  children = matchData[3]

  weights[parent] = weight.to_i

  if children
    children.split(", ").each do |child|
      structure[parent] = Array.new if structure[parent] == nil
      structure[parent].push(child)
      isAChild[child] = true
    end
  end
end


# Use weight (to get complete list of items) and isAChild to find
# the item that is _not_ a child
root = nil
weights.each do |item, weight|
  if !isAChild[item]
    root = item
    break
  end
end


# Recursively figure out the weight of a particular sub-tree
def getTreeWeight(root, structure, weights)
  return weights[root] if structure[root] == nil or structure[root].empty?

  subWeights = Hash.new
  structure[root].each do |child| 
    subWeights[child] = getTreeWeight(child, structure, weights)
  end

  if subWeights.values.uniq.length > 1
    min = subWeights.min_by{|child, weight| weight}
    max = subWeights.max_by{|child, weight| weight}
    
    toChange = nil
    delta = 0
    if subWeights.values.count(min[1]) <= 1
      # the min value is the unique one causing imbalance
      toChange = min[0]
      delta = max[1] - min[1]
    else
      # the max value is the unique one causing imbalance
      toChange = max[0]
      delta = min[1] - max[1]
    end

    puts "Change #{toChange} by #{delta} to #{weights[toChange] + delta}"
  end

  totalWeight = weights[root] + subWeights.values.inject(0){|sum, weight| sum + weight}
  return totalWeight
end


puts "#{root} is the root of the structure"

totalWeight = getTreeWeight(root, structure, weights)
puts "#{totalWeight} is the total weight of the tree"
