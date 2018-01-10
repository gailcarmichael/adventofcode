input = File.read("day09-input.txt").strip.split("")

bracketStack = []
runOfExcl = 0
totalScore = 0
totalGarbage = 0

input.each_with_index do |char, index|
  puts "#{char}  #{runOfExcl} #{bracketStack.inspect}"


  ### GARBAGE
  if bracketStack[-1] == "<" # inside of garbage
    if char == "!"
      runOfExcl += 1
    end

    charIsCancelled = (input[index-1]=="!" && runOfExcl.odd?)

    if char == ">" && !charIsCancelled
      bracketStack.pop 
    end

    if char != "!"
      runOfExcl = 0
      if !charIsCancelled && char != ">"
        totalGarbage += 1
      end
    end
  
  ### NOT GARBAGE
  else
    if char == "{"
      bracketStack.push char 
      totalScore += bracketStack.length
    elsif char == "<"
      bracketStack.push char
    elsif char == "}"
      bracketStack.pop
    end
  end
end

puts "Total score of groups is #{totalScore}"
puts "Total garbage is #{totalGarbage}"
