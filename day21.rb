input = File.read("day21-input.txt").strip


####
## Process input, saving all transformations of the rule in a hash
## with the corresponding output

def flipPattern(pattern)
  resultArray = Marshal.load(Marshal.dump(pattern))
  resultArray.each do |row|
    row[0], row[-1] = row[-1], row[0]
  end
  resultArray
end

def rotatePattern(pattern, numRotations)
  resultArray = Marshal.load(Marshal.dump(pattern))
  numRotations.times do
    rotatedArray = []
    resultArray.transpose.each do |x|
      rotatedArray << x.reverse
    end
    resultArray = Array.new(rotatedArray)
  end
  resultArray
end


allRules = Hash.new

input.split("\n").each do |line|
  ruleParts = line.split(" => ")

  pattern = ruleParts[0].split("/")
  pattern.map! {|row| row.split("")}

  output = ruleParts[1].split("/")
  output.map! {|row| row.split("")}

  allRules[pattern] = output
  allRules[flipPattern(pattern)] = output
  allRules[rotatePattern(pattern, 1)] = output
  allRules[rotatePattern(pattern, 2)] = output
  allRules[rotatePattern(pattern, 3)] = output
  allRules[flipPattern(rotatePattern(pattern, 1))] = output
  allRules[flipPattern(rotatePattern(pattern, 2))] = output
  allRules[flipPattern(rotatePattern(pattern, 3))] = output
end


####
## Get sub-patterns, apply rules and replace values in original art

def getSubpattern(pattern, rowStart, colStart, size)
  subPattern = []
  pattern[rowStart..rowStart+size-1].each do |newRow|
    subPattern.push newRow[colStart..colStart+size-1]
  end
  subPattern
end

def getAllSubpatterns(pattern, size)
  numSubPatterns = pattern.length/size
  subPatterns = Array.new(numSubPatterns) {Array.new(numSubPatterns)}
  subPatterns.each_with_index do |subArray, verNum|
    subArray.each_index do |horNum|
      subPatterns[verNum][horNum] = getSubpattern(pattern, verNum*size, horNum*size, size)
    end
  end
  subPatterns
end

def combineSubPatterns(subPatterns)
  sizeSubPattern = subPatterns[0][0].length
  numSubPatterns = subPatterns[0].length
  result = Array.new(numSubPatterns*sizeSubPattern) {Array.new(numSubPatterns*sizeSubPattern)}
  subPatterns.each_with_index do |rowOfPatterns, rowIndex|
    rowOfPatterns.each_with_index do |pattern, colIndex|
      pattern.each_with_index do |rowInPattern, rowInPatternIndex|
        rowInPattern.each_with_index do |colInPattern, colInPatternIndex|
          row = rowIndex*sizeSubPattern + rowInPatternIndex
          col = colIndex*sizeSubPattern + colInPatternIndex
          result[row][col] = colInPattern
        end
      end
    end
  end
  result
end

def applyRule(pattern, rules)
  if rules[pattern] == nil
    puts "Pattern: #{pattern}"
  end
  rules[pattern].clone
end


####
## Apply rules for some number of iterations

currentArt = [".#.".split(""), "..#".split(""), "###".split("")]

puts "Rules: "
allRules.keys.each {|key| puts "#{key.inspect}\n#{allRules[key]}\n\n"}

18.times do |i|
  if currentArt.length % 2 == 0
    subPatterns = getAllSubpatterns(currentArt, 2)
  else
    subPatterns = getAllSubpatterns(currentArt, 3)
  end
  subPatterns.each_with_index do |subPatternRow, rowIndex|
    subPatternRow.map! do |subPattern|
      applyRule(subPattern, allRules)
    end
  end
  currentArt = combineSubPatterns(subPatterns)
end

numPixelsOn = 0
currentArt.each do |row|
  row.each {|item| numPixelsOn += 1 if item == "\#"}
end

p numPixelsOn
