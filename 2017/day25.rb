input = File.read("day25-input.txt").strip.split("\n")

match = /Begin in state (.)./.match(input[0])
startState = match[1]
input.delete_at(0)

match = /Perform a diagnostic checksum after (.+) steps./.match(input[0])
numSteps = match[1].to_i
input.delete_at(0)
input.delete_at(0)

###

class StateInstructions
  attr_accessor :stateName
  attr_accessor :write_0, :move_0, :continue_0
  attr_accessor :write_1, :move_1, :continue_1
end

allStateInstructions = Hash.new

((input.length+1)/10).times do |s|
  instructions = StateInstructions.new

  match = /In state (.):/.match(input[s*10])
  instructions.stateName = match[1]


  match = /    - Write the value (.)./.match(input[s*10+2])
  instructions.write_0 = match[1].to_i

  match = /    - Move one slot to the (.+)./.match(input[s*10+3])
  instructions.move_0 = match[1]

  match = /    - Continue with state (.)./.match(input[s*10+4])
  instructions.continue_0 = match[1]


  match = /    - Write the value (.)./.match(input[s*10+6])
  instructions.write_1 = match[1].to_i

  match = /    - Move one slot to the (.+)./.match(input[s*10+7])
  instructions.move_1 = match[1]

  match = /    - Continue with state (.)./.match(input[s*10+8])
  instructions.continue_1 = match[1]

  allStateInstructions[instructions.stateName] = instructions
end

###

currentState = startState

changeDir = {"right" => 1, "left" => -1}

tape = Hash.new(0)
currX = 0

numSteps.times do
  currInstruction = allStateInstructions[currentState]

  if tape[currX] == 0
    tape[currX] = currInstruction.write_0
    currX += changeDir[currInstruction.move_0]
    currentState = currInstruction.continue_0
  else
    tape[currX] = currInstruction.write_1
    currX += changeDir[currInstruction.move_1]
    currentState = currInstruction.continue_1
  end
end

p tape.values.count(1)
