input = File.read("day13-input.txt").strip

$ranges = Hash.new
$lastLayer = 0


input.split("\n").each do |layer|
  layer = layer.split(": ")
  layerNum = layer[0].to_i
  $ranges[layerNum] = layer[1].to_i
  $lastLayer = layerNum # input is sorted asc order
end


# Determine whether a scanner with a certain range is at
# its zero position based on the current picosecond
def isScannerAtZero(range, picosecond)
  picosecond % ((range-1)*2) == 0
end


# Traverse through the layers, updating scanner positions
# as we go. Check whether we are caught and update info
# about severity if we are.
def caughtTraversingLayers(delay=0, stopWhenCaught=false)
  packetIndex = -1
  severity = 0
  caught = false

  (delay..$lastLayer+delay).each do |picosecond|

    if picosecond >= delay

      # Enter new layer
      packetIndex += 1

      # Check if scanner has caught us
      if $ranges[packetIndex] != nil && isScannerAtZero($ranges[packetIndex], picosecond)
        #severity += packetIndex * $ranges[packetIndex]
        caught = true
        break if stopWhenCaught
      end
    end
  end
  
  #puts "Severity at delay #{delay} is #{severity}"

  return caught
end


caughtTraversingLayers


delay = 0
while caughtTraversingLayers(delay, true)
  delay += 1
end

puts "The smallest delay without getting caught is #{delay}"
