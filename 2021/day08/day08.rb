class Entry
  UNIQUE_DIGIT_WIRES = {'cf'      => 1,
                        'bcdf'    => 4, 
                        'acf'     => 7, 
                        'abcdefg' => 8}
  
  OTHER_DIGITS_WIRES = {'abcefg' => 0,
                        'acdeg'  => 2,
                        'acdfg'  => 3,
                        'abdfg'  => 5,
                        'abdefg' => 6,
                        'abcdfg' => 9}

  attr_reader :wire_mappings

  def initialize(signal_patterns, output_digits)
    @signals = signal_patterns
    @output = output_digits
    @wire_mappings = Hash.new # original wire to new wire
  end

  def num_outputs_all_unique_digits
    lengths = UNIQUE_DIGIT_WIRES.keys.map{|wires| wires.length}
    @output.count{|digit| lengths.include?(digit.length)}
  end

  def determine_wire_mappings
    # a is the only common wire between signals for 1 and 7
    signal_for_1 = @signals.find{|signal| signal.length == 2}
    signal_for_7 = @signals.find{|signal| signal.length == 3}
    @wire_mappings['a'] = (signal_for_7.split('') - signal_for_1.split(''))[0]

    # Other than a, only d and f are common in the length-5 digits
    candidates_for_d = common_wires_length_5 - [@wire_mappings['a']]

    # Since d is not common among length-6 digits, any wires that are common can be eliminated
    candidates_for_d = candidates_for_d - common_wires_length_6

    puts "Didn't find single candidate for d as expected" if candidates_for_d.length != 1
    @wire_mappings['d'] = candidates_for_d[0]

    # Knowing a and d means we can figure out g using the length-5 digits
    candidates_for_g = common_wires_length_5 - [@wire_mappings['a'], @wire_mappings['d']]
    @wire_mappings['g'] = candidates_for_g[0]

    # Comparing the wires for 1 and 4 will allow us to determine what b is (since we know d already)
    signal_for_4 = @signals.find{|signal| signal.length == 4}
    candidates_for_b = signal_for_4.split('') - signal_for_1.split('') - [@wire_mappings['d']]
    @wire_mappings['b'] = candidates_for_b[0]

    # To get f, find the signal for 5 using the known value for wire b (only 5 has this wire)
    signal_for_5 = @signals.find do |signal| 
      wires = signal.split('')
      (wires.length == 5) and wires.include?(@wire_mappings['b'])
    end
    @wire_mappings['f'] = (signal_for_5.split('') - [@wire_mappings['a'], @wire_mappings['b'], @wire_mappings['d'], @wire_mappings['g']])[0]

    # Use the signal for 7 to get the wire for c
    @wire_mappings['c'] = (signal_for_7.split('') - [@wire_mappings['a'], @wire_mappings['f']])[0]

    # And finally, whatever letter is left gives us the mapping for e
    @wire_mappings['e'] = (['a','b','c','d','e','f','g'] - @wire_mappings.values)[0]
  end

  def decode_output
    if @wire_mappings.length != 7 
      puts "Wire mappings are incomplete" 
      return -1
    end

    @output.reduce("") do |result, signal|
      decoded_signal = signal.chars.reduce("") do |decoded_result, coded_wire|
        decoded_result + @wire_mappings.key(coded_wire.chars.sort.join)
      end.chars.sort.join
      
      digit = UNIQUE_DIGIT_WIRES[decoded_signal]
      digit = OTHER_DIGITS_WIRES[decoded_signal] if digit == nil

      result + digit.to_s
    end.to_i
  end

  private

  def common_wires_length_5
    signals_length_5 = 
      @signals.find_all{|signal| signal.length == 5}.map{|signal| signal.split('')}
    signals_length_5[0].intersection(signals_length_5[1], signals_length_5[2])
  end

  def common_wires_length_6
    signals_length_6 = 
      @signals.find_all{|signal| signal.length == 6}.map{|signal| signal.split('')}
    signals_length_6[0].intersection(signals_length_6[1], signals_length_6[2])
  end
end

def count_num_unique_digits(entry_list)
  entry_list.reduce(0) do |sum, entry|
    sum + entry.num_outputs_all_unique_digits
  end
end

################################################################

def process_file(filename)
  File.read(filename, chomp: true).split("\n").map do |line|
    parts = line.split(" | ")
    Entry.new(parts[0].split(" "), parts[1].split(" "))
  end
end

################################################################

# sample_line = "acedgfb cdfbe gcdfa fbcad dab cefabd cdfgeb eafb cagedb ab | cdfeb fcadb cdfeb cdbaf"
# sample_parts = sample_line.split(" | ") 
# sample_entry = Entry.new(sample_parts[0].split(" "), sample_parts[1].split(" "))
# sample_entry.determine_wire_mappings
# p sample_entry.wire_mappings
# p sample_entry.decode_output

puts
puts "Test:"
entry_list = process_file("day08-input-test.txt")
puts "\tNum unique digits: #{count_num_unique_digits(entry_list)}"
sum_of_decoded = entry_list.reduce(0) do |sum, entry| 
  entry.determine_wire_mappings
  decoded_output = entry.decode_output
  sum + decoded_output
end
puts "\tDecoded output: #{sum_of_decoded}"


puts
puts "Real:"
entry_list = process_file("day08-input.txt")
puts "\tNum unique digits: #{count_num_unique_digits(entry_list)}"
sum_of_decoded = entry_list.reduce(0) do |sum, entry| 
  entry.determine_wire_mappings
  decoded_output = entry.decode_output
  sum + decoded_output
end
puts "\tDecoded output: #{sum_of_decoded}"