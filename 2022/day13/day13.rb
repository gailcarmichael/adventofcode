def right_order?(left_packet, right_packet)
    return true if left_packet.empty? && !right_packet.empty?

    left_packet.each_with_index do |left_value, index|
        return false if right_packet.size-1 < index # right list ran out first

        right_value = right_packet[index]

        if left_value.is_a?(Integer) && right_value.is_a?(Integer)
            return true if left_value < right_value
            return false if left_value > right_value

        elsif left_value.is_a?(Array) && right_value.is_a?(Array)
            result = right_order?(left_value, right_value)
            return result if result != nil

        else
            result = nil
            if left_value.is_a? Integer
                result = right_order?([left_value], right_value)
            else
                result = right_order?(left_value, [right_value])
            end
            return result if result != nil
        end

        return true if index+1 == left_packet.size && left_packet.size < right_packet.size # left list ran out first
    end

    return nil
end

def sum_of_indices_for_pairs_in_order(pair_list)
    indices_in_order = []
    pair_list.each_with_index do |pair, index|
        if right_order?(pair[:left_packet], pair[:right_packet])
            indices_in_order.push(index+1) # change to 1-based indexing
        end
    end
    indices_in_order.inject(:+)
end

def sort_all_packets(pair_list)
    all_packets = []
    pair_list.each {|pair| all_packets += [pair[:left_packet], pair[:right_packet]]}
    all_packets += [[[2]], [[6]]]

    all_packets.sort do |packet1, packet2|
        result = right_order?(packet1, packet2)
        if result
            -1
        else
            1
        end
    end
end

def decoder_key(pair_list)
    sorted = sort_all_packets(pair_list)
    (sorted.find_index([[2]])+1) * (sorted.find_index([[6]])+1)
end

####

def process_packet(packet_string)
    list_stack = [[]]
    number_string = ""

    packet_string.split("").each do |packet_char|
        case packet_char
        when '['
            list_stack.push(Array.new)
        when ']'
            if !number_string.empty?
                list_stack[-1].push(number_string.to_i)
                number_string = ""
            end
            last_list = list_stack.pop
            list_stack[-1].push(last_list)
        when ','
            if !number_string.empty?
                list_stack[-1].push(number_string.to_i)
                number_string = ""
            end
        else
            number_string += packet_char
        end
    end

    list_stack[0][0]
end

def process_file(filename)
    File.read(filename).split("\n\n").map do |pair_lines|
        packets = pair_lines.split("\n")
        {left_packet: process_packet(packets[0]),
         right_packet: process_packet(packets[1])}
    end
end


packet_pairs_test = process_file("day13-input-test.txt")
puts "Sum of indices in order (test): #{sum_of_indices_for_pairs_in_order(packet_pairs_test)}"
puts "Decoder key: (test): #{decoder_key(packet_pairs_test)}"

packet_pairs_real = process_file("day13-input.txt")
puts "Sum of indices in order (real): #{sum_of_indices_for_pairs_in_order(packet_pairs_real)}"
puts "Decoder key: (real): #{decoder_key(packet_pairs_real)}"