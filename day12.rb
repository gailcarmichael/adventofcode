require 'set'

input = File.read("day12-input.txt").strip()

edges = {}

# Create graph structure from input
input.split("\n").each do |line|
  lineParts = line.split(" <-> ")
  node = lineParts[0]
  lineParts[1].split(", ").each do |otherNode|
    edges[node] = Array.new if !edges.has_key? node
    edges[node].push otherNode
  end
end

# Find all nodes connected with the given node
def getConnectedNodes(node, edges, results={})
  if (!results.has_key?(node))
    results[node] = Set.new
    currResults = Set.new
    edges[node].each do |otherNode|
      currResults.add otherNode
      currResults = currResults | getConnectedNodes(otherNode, edges, results)
    end
    results[node] = results[node] | currResults
  end
  results[node]
end

# Output how many nodes are connected to 0
connectedNodes = getConnectedNodes("0", edges)
puts "There are #{connectedNodes.size} nodes connected to 0"

# Determine how many groups of nodes there are
groups = Hash.new
edges.keys.each do |node|
  connected = getConnectedNodes(node, edges)
  groups[connected] = true
end

puts "There are #{groups.size} different connected node groups"
