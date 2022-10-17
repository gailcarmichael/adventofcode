def knotHash(input)
  list = (0..255).to_a

  currListPos = 0
  skipSize = 0


  #############
  # Process input: use each character's ASCII value instead,
  # then add the standard length suffix values

  lengths = input.split("")
  lengths.map! {|l| l.ord}

  lengths += [17, 31, 73, 47, 23]


  #############
  # Do 64 rounds of traversing through the length array, using
  # the position and skip size from the previous round without
  # resetting

  64.times do

    lengths.each do |length|

      # extract the sublist we need to reverse, reverse it,
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

  end

  #############
  # Create a dense hash from the list

  denseHash = []
  (0..15).each do |blockNum|
    # XOR all the numbers in the current block
    startIndex = blockNum*16
    result = list[startIndex..startIndex+15].inject(0) do |xor,item|
      xor = xor ^ item
    end
    denseHash.push(result)
  end

  #############
  # Output the hash as hex

  hexHash = ""
  denseHash.each do |decimalNum|
    hexHash += decimalNum.to_s(16).rjust(2, '0')
  end

  hexHash
end

