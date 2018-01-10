input = "63,144,180,149,1,255,167,84,125,65,188,0,2,254,229,24"

lengths = input.split(",")
lengths.map! {|l| l.to_i}

list = (0..255).to_a

currListPos = 0
skipSize = 0

lengths.each do |length|

  # extract the sublist we need to revserse, reverse it,
  # then put it back

  tempList = []

  (currListPos..currListPos+length-1).each do |index|
    tempList.push(list[index % list.length])
  end

  tempList.reverse!

  listIndex = currListPos
  tempList.each_with_index do |tempItem, tempIndex|
    list[(listIndex + tempIndex) % list.length] = tempItem
  end

  #puts list.inspect

  currListPos += length + skipSize
  currListPos = currListPos % list.length
  skipSize += 1
end

puts "The first two numbers multiplied together gives #{list[0]*list[1]}"
