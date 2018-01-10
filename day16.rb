input = File.read("day16-input.txt").strip
danceMoves = input.split(",")

originalPrograms = 'abcdefghijklmnop'.split("")
programs = Array.new(originalPrograms)

def doDanceMoveCycle(programs, danceMoves)
  danceMoves.each do |danceMove|
    if danceMove[0] == 's'
      x = danceMove.split('s')[1].to_i
      endPrograms = programs[(programs.length-x..programs.length)]
      programs[0..programs.length-x-1].each {|x| endPrograms.push x}
      programs = endPrograms
    elsif danceMove[0] == 'x'
      split = danceMove[(1..-1)].split("/")
      a = split[0].to_i
      b = split[1].to_i
      temp = programs[a]
      programs[a] = programs[b]
      programs[b] = temp
    elsif danceMove[0] == 'p'
      split = danceMove[(1..-1)].split("/")
      a = split[0]
      b = split[1]
      programAtA = programs[programs.index(a)]
      indexOfA = programs.index programAtA
      programAtB = programs[programs.index(b)]
      indexOfB = programs.index programAtB
      programs[indexOfA] = programAtB
      programs[indexOfB] = programAtA
    end
  end
  programs
end

cycleSize = 0

loop do
  programs = doDanceMoveCycle(programs, danceMoves)
  cycleSize += 1
  break if programs == originalPrograms
end

cyclesLeft = 1000000000 % cycleSize
  
cyclesLeft.times do
  programs = doDanceMoveCycle(programs, danceMoves)
end

p programs.join("")
