input = File.read("day05-input.txt").strip

instructions = input.split("\n")
instructions.map! {|val| val.to_i}

instructionsCopy = Array.new(instructions)


#######################################


currIndex = 0
nextIndex = 0
numSteps = 0

while instructions[currIndex] != nil

  #puts "instructions[#{currIndex}]=#{instructions[currIndex]}"

  nextIndex = currIndex + instructions[currIndex]

  instructions[currIndex] += 1
  currIndex = nextIndex
  numSteps += 1

end

puts "#{numSteps} jumps to exit maze with simple rule"


#######################################


currIndex = 0
nextIndex = 0
numSteps = 0

while instructionsCopy[currIndex] != nil

  nextIndex = currIndex + instructionsCopy[currIndex]

  if (instructionsCopy[currIndex] >= 3)
    instructionsCopy[currIndex] -= 1
  else
    instructionsCopy[currIndex] += 1
  end

  currIndex = nextIndex
  numSteps += 1

end

puts "#{numSteps} jumps to exit maze with more complex rule"


