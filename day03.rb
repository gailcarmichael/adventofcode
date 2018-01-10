#################
# Move around the spiral until we get to the input number,
# calculating the x/y coordinates along the way.

# Cycle through right, up, left, down, adding another move
# in the same direction every second switch to get the pattern
# R U LL DD RRR UUU LLLL DDDD RRRRR UUUUU etc

class SpiralMemory

  ################# 
  # Amount to add to coordinates when moving Right, Up, Left, Down,
  # using the "positive y does down" model
  @@dirs = ["r", "u",  "l", "d"]
  @@dx =   [ 1,   0,   -1,   0]
  @@dy =   [ 0,  -1,    0,   1]


  def initialize(input)
    @inputNumber = input

    @currentNumber = 0

    @currX = 0
    @currY = 0

    @currentDirIndex = 0

    @stressTestGrid = Hash.new
    @stressTestGrid[[0,0]] = 1
    @foundStressTestAnswer = false
  end


  def checkForAnswer()
    if @currentNumber == @inputNumber
      manhattanDist = @currX.abs + @currY.abs
      puts "*** The distance for #{@inputNumber} is #{manhattanDist} ***"
    end
  end

  def checkForStressTestAnswer()
    return if @foundStressTestAnswer
    gridNum = @stressTestGrid[[@currX, @currY]]
    if gridNum > @inputNumber
      puts "--- The first stress test number bigger than input is #{gridNum}"
      @foundStressTestAnswer = true
    end
  end


  def updateStressTestGrid()
    return if @currentNumber == 1 # Seeded in class initializer
    totalNeighbours = 0;
    (-1..1).each do |col|
      (-1..1).each do |row|
        next if col == 0 and row == 0
        neighbour = @stressTestGrid[[@currX + col, @currY + row]]
        totalNeighbours += neighbour if (neighbour != nil)
      end
    end
    @stressTestGrid[[@currX, @currY]] = totalNeighbours
  end


  def advanceSpiralAndCheckAnswers(numTimes)
    (1..numTimes).each do
      @currentNumber += 1
      updateStressTestGrid()

      checkForAnswer()
      checkForStressTestAnswer()

      @currX += @@dx[@currentDirIndex]
      @currY += @@dy[@currentDirIndex]

      #puts "#{@currentNumber} #{@currX} #{@currY} #{@@dirs[@currentDirIndex]}"
    end
  end


  def updateDirection()
    @currentDirIndex = (@currentDirIndex + 1) % 4
  end


  def goAroundSpiral
    timesToRepeatDir = 1

    until @currentNumber >= @inputNumber and @foundStressTestAnswer
 
      # There are always two groups of the same direction in a row;
      # how many times to move in that direction is what changes
      # to give the direction change pattern shown above
  
      advanceSpiralAndCheckAnswers(timesToRepeatDir)
      updateDirection()
    
      advanceSpiralAndCheckAnswers(timesToRepeatDir)
      updateDirection()

      # After the two groups, we need to increase the number of repeats
      timesToRepeatDir += 1
    end
  end

end

SpiralMemory.new(277678).goAroundSpiral
