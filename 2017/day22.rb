input = File.read('day22-input.txt').strip

lines = input.split("\n")
middleIndex = (lines[0].length / 2.0).to_i

grid = Hash.new('.')

lines.each_with_index do |line, row|
  line.split("").each_with_index do |char, col|
    grid[[col-middleIndex, row-middleIndex]] = char if char == '#'
  end
end


####
## Do some bursts

currX = 0
currY = 0

currDir = :n
turnLeft = {n: :w, w: :s, s: :e, e: :n}
turnRight = {n: :e, e: :s, s: :w, w: :n}
reverse = {n: :s, e: :w, s: :n, w: :e}

numInfectionsCaused = 0

10000000.times do |burstNum|
  case grid[[currX,currY]]
  when '.'
    currDir = turnLeft[currDir]
    grid[[currX,currY]] = 'W'
  when 'W'
    grid[[currX,currY]] = '#'
    numInfectionsCaused += 1
  when '#'
    currDir = turnRight[currDir]
    grid[[currX,currY]] = 'F'
  when 'F'
    currDir = reverse[currDir]
    grid[[currX,currY]] = '.'
  end

  case currDir
  when :n
    currY -= 1
  when :e
    currX += 1
  when :s
    currY += 1
  when :w
    currX -= 1
  end
end

p numInfectionsCaused
