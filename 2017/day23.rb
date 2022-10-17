require 'prime'

input = File.read("day23-input.txt").strip

instructionList = input.split("\n")

registers = Hash.new(0)

def getValue(registers, arg)
  if arg =~ /[[:digit:]]/
    return arg.to_i
  else
    return registers[arg]
  end
end

numTimesMul = 0

currIndex = 0
while currIndex >= 0 && currIndex < instructionList.length
  parts = instructionList[currIndex].split(" ")
  case parts[0]
  when 'set'
    registers[parts[1]] = getValue(registers, parts[2])
  when 'sub'
    registers[parts[1]] -= getValue(registers, parts[2])
  when 'mul'
    registers[parts[1]] *= getValue(registers, parts[2])
    numTimesMul += 1
  when 'jnz'
    if getValue(registers, parts[1]) != 0
      currIndex += getValue(registers, parts[2]) - 1
    end
  end
  currIndex += 1
end

#p numTimesMul

############################

# Part two, based on notes text files where I analyzed the program given by hand
# and now just need a little help with code

b = 84
b *= 100
b += 100000


c = b
c += 17000

h = 0

while b <= c do # b's loop
  
  # Can it happen that d*e - b = 0?
  # If so, f is set to zero at some point in d's and e's loops.
  # If so, h is decreased by 1

  # d*e = b can happen iff b is NOT prime

  h += 1 if !b.prime?

  b += 17
end

p h
