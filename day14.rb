require_relative 'knot-hash'

input = "jxqlasbh"

rows = []
totalUsed = 0
currRegionNum = 0
totalRegions = 0


# Create the grid and count how many 1's are in it as we go
(0..127).each do |rowNum|
  knotHash = knotHash(input + "-" + rowNum.to_s)
  binary = [knotHash].pack('H*').unpack('B*')[0]
  totalUsed += binary.count('1')
  rows.push(binary.split(""))
end

# Change numerical grid to one representing regions
rows.each_with_index do |row, rowNum|
  row.each_with_index do |item, colNum|

    if item == '1'

      adjacents = Array.new

      # Check for prior adjacent regions (up, left)
      if rowNum > 0
        if rows[rowNum-1][colNum].is_a? Integer
          adjacents.push rows[rowNum-1][colNum]
        end
      end
      if colNum > 0
        if rows[rowNum][colNum-1].is_a? Integer
          adjacents.push rows[rowNum][colNum-1]
        end
      end

      adjacents = adjacents.uniq

      if adjacents.length == 0 # Create a new region

        totalRegions += 1
        currRegionNum += 1
        rows[rowNum][colNum] = currRegionNum

      elsif adjacents.length == 1 # Continue existing region

        rows[rowNum][colNum] = adjacents[0]

      else # Merge regions

        totalRegions -= 1

        # Replace first region num everywhere with second
        rows.each do |row|
          row.map! {|rowItem|  rowItem == adjacents[0] ? adjacents[1] : rowItem}
        end

        # Set our current space
        rows[rowNum][colNum] = adjacents[1]
      end
    end
  end
end


puts "Total spaces used is #{totalUsed}"
puts "Total regions present: #{totalRegions}"

