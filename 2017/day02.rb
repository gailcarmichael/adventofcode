input = File.read("day02-input.txt").strip

rows = input.split("\n")
sum = 0
sum2 = 0

rows.each do |row|
  cols = row.split(" ")
  cols.map! {|val| val.to_i}

  sum += cols.max - cols.min

  cols.sort!
  cols.reverse!

  cols.each_with_index do |val, index|
    next if index == cols.length-1

    cols[index+1..-1].each do |secondVal|
      if val % secondVal == 0
        sum2 += val / secondVal
      end
    end

  end
end

puts "The first checksum is #{sum}"
puts "The second checksum is #{sum2}"
