class AntennaField

  attr_reader :antinode_list

  def initialize
    @max_row = @max_col = 0
    @ind_antenna_grids = Hash.new{|h,k| h[k] = Hash.new('.')}
    @antinode_list = Array.new
  end

  def add_antenna(row, col, char)
    @ind_antenna_grids[char][[row,col]] = char

    @max_row = [@max_row, row].max
    @max_col = [@max_col, col].max
  end

  def add_all_antinodes(harmonics=false)
    @ind_antenna_grids.each_pair do |char, grid|
      harmonics ? add_antinodes_for_antenna_type_harmonics(char) : add_antinodes_for_antenna_type_simple(char)
    end
  end

  #########
  # Part 1 (simple antinodes)

  def add_antinodes_for_antenna_type_simple(char)
    antenna_grid = @ind_antenna_grids[char]
    antenna_grid.select{|loc,char| char != '.'}.keys.combination(2) do |a1, a2|
      if (@max_col*a1[0] + a1[1]) > (@max_col*a2[0] + a2[1])
        a1, a2 = a2, a1
      end

      d_row = a2[0]-a1[0]
      d_col = a2[1]-a1[1]

      antinode1 = [a1[0] - d_row, a1[1] - d_col]
      antinode2 = [a2[0] + d_row, a2[1] + d_col]

      if (antinode1[0].between?(0,@max_row) && antinode1[1].between?(0,@max_col))
        @antinode_list.push(antinode1)
      end

      if (antinode2[0].between?(0,@max_row) && antinode2[1].between?(0,@max_col))
        @antinode_list.push(antinode2)
      end
    end
  end

  #########
  # Part 2 (harmonics antinodes)

  def add_antinodes_for_antenna_type_harmonics(char)
    antenna_grid = @ind_antenna_grids[char]
    antenna_grid.select{|loc,char| char != '.'}.keys.combination(2) do |a1, a2|
      if (@max_col*a1[0] + a1[1]) > (@max_col*a2[0] + a2[1])
        a1, a2 = a2, a1
      end

      d_row = a2[0]-a1[0]
      d_col = a2[1]-a1[1]

      # Go 'up left'
      next_antinode = a1
      loop do
        break if (!next_antinode[0].between?(0,@max_row)) || (!next_antinode[1].between?(0,@max_col))
        @antinode_list.push(next_antinode)
        next_antinode = [next_antinode[0] - d_row, next_antinode[1] - d_col]
      end

      # Go 'down right'
      next_antinode = a2
      loop do
        break if (!next_antinode[0].between?(0,@max_row)) || (!next_antinode[1].between?(0,@max_col))
        @antinode_list.push(next_antinode)
        next_antinode = [next_antinode[0] + d_row, next_antinode[1] + d_col]
      end
    end
  end
end

##########################

def process_file(filename)
  field = AntennaField.new
  File.read(filename).strip.split("\n").each_with_index do |line, row|
    line.split("").each_with_index {|char, col| field.add_antenna(row, col, char)}
  end
  field
end

puts
field = process_file("day08-input-test.txt")
field.add_all_antinodes
puts "Unique locations with antinodes (test): #{field.antinode_list.uniq.length}"

field = process_file("day08-input-test.txt")
field.add_all_antinodes(true)
puts "Unique locations with antinodes and harmonics (test): #{field.antinode_list.uniq.length}"

puts
field = process_file("day08-input.txt")
field.add_all_antinodes
puts "Unique locations with antinodes (real): #{field.antinode_list.uniq.length}"

field = process_file("day08-input.txt")
field.add_all_antinodes(true)
puts "Unique locations with antinodes and harmonics (real): #{field.antinode_list.uniq.length}"
