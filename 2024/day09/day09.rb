class DiskMap
  def initialize
    @block_list = Array.new

    # used for part 2 only
    @file_indexes_to_sizes = Hash.new
    @space_indexes_to_sizes = Hash.new

    # used for part 1 only
    @last_file_space_index = -1
    @first_free_space_index = -1
    @last_free_space_index = -1
  end

  def to_s
    return "." if @block_list.empty?
    @block_list.join
  end

  def add_file(id, size)
    first_add = (@last_file_space_index < 0)

    @last_file_space_index = @last_free_space_index if !first_add

    @file_indexes_to_sizes[@block_list.length] = size

    1.upto(size) do
      @block_list.push id
      @last_file_space_index += 1
    end

  end

  def add_spaces(num_spaces)
    first_add = (@first_free_space_index < 0)

    if first_add
      @first_free_space_index = @last_file_space_index + 1
      @last_free_space_index = @last_file_space_index
    else
      @last_free_space_index = @last_file_space_index
    end

    @space_indexes_to_sizes[@block_list.length] = num_spaces

    1.upto(num_spaces) do
      @block_list.push "."
      @last_free_space_index += 1
    end
  end

  def checksum
    0.upto(@block_list.length-1).map do |index|
      if @block_list[index] == "."
        0
      else
        index * @block_list[index]
      end
    end.sum
  end

  ########
  # Part 1

  def move_blocks_until_no_gaps
    loop do
      break if @first_free_space_index >= @last_file_space_index
      move_last_block_to_first_free_space
    end
  end

  def move_last_block_to_first_free_space
    # move the last file block to the first free space
    @block_list[@first_free_space_index] = @block_list.pop

    # update where the last file block is
    (@last_file_space_index - 1).downto(0) do |index|
      if @block_list[index] != "."
        @last_file_space_index = index
        @block_list = @block_list[0..@last_file_space_index]
        break
      end
    end

    # update where the first free block is (since the old one was just replaced)
    (@first_free_space_index + 1).upto(@block_list.length) do |index|
      if index == @block_list.length
        @first_free_space_index = @last_free_space_index = index
        return # no more free spaces left
      elsif @block_list[index] == "."
        @first_free_space_index = index
        break
      end
    end

    # remove the file item that was moved, and any trailing whitespaces
    (@block_list.length-1).downto(@last_file_space_index + 1) {|index| @block_list.pop }

    # find the last free space
    (@block_list.length-1).downto(0) do |index|
      if @block_list[index] == "."
        @last_free_space_index = index
        break
      end
    end
  end

  ########
  # Part 2

  def move_files_while_possible
    @file_indexes_to_sizes.keys.reverse.each do |file_index|
      file_size = @file_indexes_to_sizes[file_index]
      possible_spaces = @space_indexes_to_sizes.select do |space_index, space_size|
        space_index < file_index && space_size >= file_size
      end
      if (!possible_spaces.empty?)
        space_index = possible_spaces.keys.sort[0]
        move_file_to_space(file_index, file_size, space_index, @space_indexes_to_sizes[space_index])
      end

      # pop off any extra empty spaces
      (@block_list.length-1).downto(0) do |index|
        break if (@block_list[index] != ".")
        @block_list.pop
      end
    end
  end

  def move_file_to_space(file_index, file_size, space_index, space_size)
    file_id = @block_list[file_index]

    # move the file to the free space
    space_index.upto(space_index + file_size - 1) do |curr_index|
      @block_list[curr_index] = file_id
    end

    # update the spaces-index-to-size hash
    new_space_size = @space_indexes_to_sizes[space_index] - file_size
    @space_indexes_to_sizes.delete(space_index)
    if new_space_size > 0
      @space_indexes_to_sizes[space_index + file_size] = new_space_size
    end

    # replace the old file location with spaces
    file_index.upto(file_index+file_size-1) do |index|
      @block_list[index] = "."
    end
  end

end

#########################

def process_file(filename)
  disk_map = DiskMap.new
  File.read(filename).strip.split("").each_with_index do |char, index|
    if index.even?
      disk_map.add_file(index/2, char.to_i)
    else
      disk_map.add_spaces(char.to_i)
    end
  end
  disk_map
end


puts
disk_map = process_file("day09-input-test1.txt")
disk_map.move_blocks_until_no_gaps
puts "Disk map after filling empty spaces (test 1): #{disk_map}"
puts "Checksum (test 1): #{disk_map.checksum}"

puts
disk_map = process_file("day09-input-test2.txt")
disk_map.move_blocks_until_no_gaps
puts "Disk map after filling empty spaces (test 2): #{disk_map}"
puts "Checksum (test 2): #{disk_map.checksum}"

puts
disk_map = process_file("day09-input-test2.txt")
disk_map.move_files_while_possible
puts "Disk map after filling empty spaces (test 2): #{disk_map}"
puts "Checksum (test 2): #{disk_map.checksum}"


puts
disk_map = process_file("day09-input.txt")
disk_map.move_blocks_until_no_gaps
puts "Checksum (real): #{disk_map.checksum}"

puts
disk_map = process_file("day09-input.txt")
disk_map.move_files_while_possible
puts "Checksum (real): #{disk_map.checksum}"
