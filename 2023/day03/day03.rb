require 'set'

def is_actual_part?(schematic, part)
  coord_to_symbol = schematic[:coord_to_symbol]

  # For each digit of the part length, check all around for non-period symbols
  # (technically this is more checks than required in some cases, but the code is simpler)
  line_num = part[:start_coord][0]
  first_index = part[:start_coord][1]

  first_index.upto(first_index + part[:length] - 1).any? do |index|
    coord_to_symbol[[line_num-1, index-1]] != "." ||
      coord_to_symbol[[line_num-1, index]] != "." ||
      coord_to_symbol[[line_num-1, index+1]] != "." ||
      coord_to_symbol[[line_num,   index-1]] != "." ||
      coord_to_symbol[[line_num,   index+1]] != "." ||
      coord_to_symbol[[line_num+1, index-1]] != "." ||
      coord_to_symbol[[line_num+1, index]] != "." ||
      coord_to_symbol[[line_num+1, index+1]] != "."
  end
end

def sum_part_numbers(schematic)
  schematic[:part_list].filter do |part|
    is_actual_part?(schematic, part)
  end.sum {|part| part[:part_num].to_i}
end

########

def collect_all_adjacent_parts_for_stars(schematic)
  symbol_coord_to_adjacent_parts = Hash.new
  schematic[:coord_to_symbol].each do |coord, symbol|
    next if symbol != "*"
    adjacent_parts = Set.new
    -1.upto(1).each do |line_delta|
      -1.upto(1).each do |index_delta|
        next if line_delta == 0 && index_delta == 0
        curr_coord = [coord[0]+line_delta, coord[1]+index_delta]
        if schematic[:coord_to_part_index].has_key?(curr_coord)
          adjacent_parts.add(schematic[:coord_to_part_index][curr_coord])
        end
      end
    end
    symbol_coord_to_adjacent_parts[coord] = adjacent_parts
  end
  symbol_coord_to_adjacent_parts
end

def find_gears(schematic)
  collect_all_adjacent_parts_for_stars(schematic).filter do |coord, parts|
    parts.length == 2
  end.values
end

def sum_of_gear_ratios(schematic)
  find_gears(schematic).sum do |parts|
    parts_array = parts.to_a
    schematic[:part_list][parts_array[0]][:part_num].to_i * schematic[:part_list][parts_array[1]][:part_num].to_i
  end
end

########

def process_file(filename)
  part_list = Array.new
  coord_to_part_index = Hash.new
  coord_to_symbol = Hash.new('.')

  File.read(filename).strip.split("\n").each_with_index do |line, line_num|

    # Find part numbers first
    matches = line.match(/(\d+)/)
    while (matches)

      part_number = matches[1]
      part_index = matches.begin(0)
      part_coord = [line_num, part_index]

      part_list.push({part_num: part_number, start_coord: part_coord, length: part_number.length})
      part_index.upto(part_index+part_number.length-1) do |curr_index|
        coord_to_part_index[[line_num, curr_index]] = part_list.length-1
      end

      matches = line.match(/(\d+)/, matches.begin(0) + matches[1].length)
    end

    # Find non-period symbols and add to schematic
    line.split("").each_with_index do |char, index|
      if (char.match?(/[^\.\d]/))
        coord_to_symbol[[line_num, index]] = char
      end
    end

  end

  {part_list: part_list,
    coord_to_part_index: coord_to_part_index,
    coord_to_symbol: coord_to_symbol}
end

########

puts "Sum of part numbers (test): #{sum_part_numbers(process_file("day03-input-test.txt"))}"
puts "Sum of part numbers (real): #{sum_part_numbers(process_file("day03-input.txt"))}"

puts "Sum of gear ratios (test): #{sum_of_gear_ratios(process_file("day03-input-test.txt"))}"
puts "Sum of gear ratios (real): #{sum_of_gear_ratios(process_file("day03-input.txt"))}"
