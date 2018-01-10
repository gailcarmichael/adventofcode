generatorAStart = 65
generatorBStart = 8921

generatorAFactor = 16807
generatorBFactor = 48271

divisor = 2147483647


numIterations = 5000000

generatorAValues = []
generatorBValues = []

generatorACurr = generatorAStart
generatorBCurr = generatorBStart


# Find first values that are multiples of 4 and 8
while generatorACurr % 4 != 0
  generatorACurr = (generatorACurr * generatorAFactor) % divisor
end
while generatorBCurr % 8 != 0
  generatorBCurr = (generatorBCurr * generatorBFactor) % divisor
end


# Add values to compare as multiples
while [generatorAValues.length, generatorBValues.length].min < numIterations
  generatorACurr = (generatorACurr * generatorAFactor) % divisor
  generatorAValues.push generatorACurr if generatorACurr % 4 == 0

  generatorBCurr = (generatorBCurr * generatorBFactor) % divisor
  generatorBValues.push generatorBCurr if generatorBCurr % 8 == 0
end


numMatches = 0

numIterations.times do |iterNum|
  mask = 0xFFFF

  if (mask & generatorAValues[iterNum]) == (mask & generatorBValues[iterNum])
    numMatches += 1
  end
end


p numMatches
