require 'pry'

input = File.read("day24-input.txt").strip

class Port
  attr_reader :pins1, :pins2

  def initialize(pins1, pins2)
    @pins1 = pins1
    @pins2 = pins2
  end

  def to_s
    "(#{@pins1}, #{@pins2})"
  end

  def ==(other)
    return @pins1 == other.pins1 && @pins2 == other.pins2
  end
end

class Node
  attr_accessor :port, :children, :parent, 
                :strongestWeight, :longestWeight, :longestHeight

  def initialize(port, parent)
    @port = port
    @children = []
    @parent = parent
    @strongestWeight = 0
    @longestHeight = 0
    @longestWeight = 0
    @height = 0
  end

  def indentedTree(indentLevel)
    s = ""
    indentLevel.times {s+="\t"}
    s += "Node with port #{@port} and strongestWeight #{@strongestWeight}\n"
    children.each {|child| s+=child.indentedTree(indentLevel+1)}
    s
  end

  def to_s
    indentedTree(0)
  end

end

###

allPorts = []

input.split("\n").each do |line|
  pins = line.split('/')
  allPorts << Port.new(pins[0].to_i, pins[1].to_i)
end


def buildBridgesTree(currentNode, allPorts)
  currentPort = currentNode.port

  if currentNode.parent != nil
    pins1Used = currentNode.parent.port.pins1 == currentNode.port.pins1 ||
                currentNode.parent.port.pins2 == currentNode.port.pins1
    pinsToUse = pins1Used ? currentPort.pins2 : currentPort.pins1
  else
    pinsToUse = currentPort.pins1
  end

  maxChildWeight = 0
  longestSubtreeHeight = 0
  longestSubtreeWeight = 0
  allPorts.each do |newPort|
    if pinsToUse == newPort.pins1 || pinsToUse == newPort.pins2
      allPortsCopy = allPorts.clone
      allPortsCopy.delete_if {|p| p == newPort}

      subtreeRoot = Node.new(newPort, currentNode)
      buildBridgesTree(subtreeRoot, allPortsCopy)

      currentNode.children.push subtreeRoot

      if subtreeRoot.strongestWeight > maxChildWeight
        maxChildWeight = subtreeRoot.strongestWeight
      end

      if subtreeRoot.longestHeight > longestSubtreeHeight
        longestSubtreeHeight = subtreeRoot.longestHeight
        longestSubtreeWeight = subtreeRoot.longestWeight
      elsif subtreeRoot.longestHeight == longestSubtreeHeight
        if  subtreeRoot.longestWeight > longestSubtreeWeight
          longestSubtreeHeight = subtreeRoot.longestHeight
          longestSubtreeWeight = subtreeRoot.longestWeight
        end
      end
    end
  end

  currentNode.strongestWeight = maxChildWeight + currentNode.port.pins1 + currentNode.port.pins2
  currentNode.longestHeight = longestSubtreeHeight + 1
  currentNode.longestWeight = longestSubtreeWeight + currentNode.port.pins1 + currentNode.port.pins2
end

startingPort = Port.new(0, 0)
root = Node.new(startingPort, nil)
allPortsCopy = allPorts.map {|port| port.clone}

buildBridgesTree(root, allPortsCopy)

puts "#{root.port.to_s} with max weight #{root.strongestWeight}, longestHeight #{root.longestHeight}, longestWeight #{root.longestWeight}"
