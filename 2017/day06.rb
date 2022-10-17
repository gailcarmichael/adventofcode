input = File.read("day06-input.txt").strip


memoryBanks = input.split(" ")
memoryBanks.map! {|val| val.to_i}

puts memoryBanks.inspect

pastConfigs = Hash.new
stepNum = 0

while pastConfigs[memoryBanks] == nil

  stepNum += 1
  pastConfigs[Array.new(memoryBanks)] = stepNum

  index = memoryBanks.index(memoryBanks.max)
  toDistribute = memoryBanks[index]
  memoryBanks[index] = 0 # reset prior to redistribution

  index = (index + 1) % memoryBanks.length
  while toDistribute > 0
    memoryBanks[index] += 1
    toDistribute -= 1
    index = (index + 1) % memoryBanks.length
  end

  #puts pastConfigs.inspect
end

stepsSinceDuplicate = pastConfigs.length - pastConfigs[memoryBanks] + 1

puts "It took #{pastConfigs.length} redistributions to see a prior config"
puts "The last configuration was seen #{stepsSinceDuplicate} steps ago"
