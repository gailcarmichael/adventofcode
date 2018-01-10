input = File.read("day18-input.txt").strip

instructionList = input.split("\n")

registers = Hash.new(0)
lastFrequency = -1

def getValue(registers, arg)
  if arg =~ /[[:digit:]]/
    return arg.to_i
  else
    return registers[arg]
  end
end

currIndex = 0
while currIndex >= 0 && currIndex < instructionList.length
  parts = instructionList[currIndex].split(" ")
  case parts[0]
  when 'snd' # play a sound
    puts "Playing sound with frequency #{registers[parts[1]].to_i}"
    lastFrequency = getValue(registers, parts[1])
  when 'set'
    registers[parts[1]] = getValue(registers, parts[2])
  when 'add'
    registers[parts[1]] += getValue(registers, parts[2])
  when 'mul'
    registers[parts[1]] *= getValue(registers, parts[2])
  when 'mod'
    registers[parts[1]] %= getValue(registers, parts[2])
  when 'rcv'
    if getValue(registers, parts[1]) != 0
      puts "Last frequency played was #{lastFrequency}"
      break
    end
  when 'jgz'
    if getValue(registers, parts[1]) > 0
      currIndex += getValue(registers, parts[2]) - 1
    end
  end
  currIndex += 1
end
