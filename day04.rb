input = File.read("day04-input.txt").strip

passphrases = input.split("\n")

numValid = 0
numValidAnagram = 0

passphrases.each do |phrase|
  words = phrase.split(" ")
  words.sort!

  sortedWords = Array.new(words)
  sortedWords.each_with_index do |word, index|
    sortedWords[index] = sortedWords[index].chars.sort.join
    puts sortedWords, "\n"
  end

  sortedWords.sort!


  ####
  # Part 1 of problem checks for duplicate words

  numValid += 1 # assume valid until proven otherwise
  words.each_with_index do |word, index|
    break if index == words.length-1
    if word == words[index + 1]
      numValid -= 1
      break
    end
  end


  ####
  # Part 2 of problem checks for duplicate anagrams
  numValidAnagram += 1 # assume valid until proven otherwise
  sortedWords.each_with_index do |word, index|
    break if index == sortedWords.length-1
    if word == sortedWords[index + 1]
      numValidAnagram -= 1
      break
    end
  end
end

puts "#{numValid} phrases are valid"
puts "#{numValidAnagram} phrases are valid for anagrams"
