input = File.read("day19-input.txt")

grid = Hash.new(' ')

currX = nil
currY = nil

charsEncountered = []
dx = 0
dy = 1

numSteps = 0

# Fill in the grid from the input
input.split("\n").each_with_index do |line, lineIndex|
  (0..(line.length-1)).each do |charIndex|
    if line[charIndex] != ' '
      grid[[charIndex, lineIndex]] = line[charIndex]
      if  currX == nil # set starting point
        currX = charIndex
        currY = lineIndex
      end
    end
  end
end

# Travel through the line
loop do
  currCharacter = grid[[currX, currY]]
  puts "#{currX}, #{currY} -> #{currCharacter}"
  
  case currCharacter
  when ' '
    puts "Finished!"
    break
  when '|'
  when '-'
  when '+'
    if dx != 0 # will go up or down from here
      dx = 0
      dy = grid[[currX, currY-1]] != ' ' ? -1 : 1
    elsif dy != 0 # will go left or right from here
      dy = 0
      dx = grid[[currX-1, currY]] != ' ' ? -1 : 1
    end
  else # character to save
    charsEncountered.push(currCharacter)
  end

  currX += dx
  currY += dy
  numSteps += 1
end

p charsEncountered.join("")
p numSteps
