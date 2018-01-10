numSteps = 382

buffer = [0]
currPos = 0

(1..2017).each do |iterNum|
  currPos = (currPos + numSteps) % buffer.length
  buffer.insert(currPos + 1, iterNum)
  currPos += 1
end

puts "Value after 2017 is #{buffer[(currPos + 1) % buffer.length]}"

###

afterZero = nil
currPos = 0
(1..50000000).each do |iterNum|
  currPos = (currPos + numSteps) % iterNum
  if currPos == 0
    afterZero = iterNum
    puts "#iterNum=#{iterNum}, afterZero=#{afterZero}"
  end
  currPos += 1
end
