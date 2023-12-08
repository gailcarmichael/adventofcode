def points_for_card(winners, yours)
  num_winners_in_yours = winners.count do |winner|
    yours.include?(winner)
  end
  return 0 if num_winners_in_yours == 0
  2**(num_winners_in_yours-1)
end

def sum_points_all_cards(card_list)
  card_list.sum {|card| points_for_card(card[:winners], card[:yours])}
end

####

def num_matches(winners, yours)
  winners.count do |winner|
    yours.include?(winner)
  end
end

def play_actual_rules(card_list)
  num_copies_of_cards = Hash.new(1)
  0.upto(card_list.length-1) {|card_number| num_copies_of_cards[card_number] = 1}

  card_list.each_with_index do |card, card_number|
    matches = num_matches(card[:winners], card[:yours])

    next if matches == 0

    # Add copies of the appropriate number of next cards
    (card_number+1).upto(card_number+matches) do |copied_card_number|
      num_copies_of_cards[copied_card_number] += num_copies_of_cards[card_number]
    end
  end
  num_copies_of_cards.values.sum
end

####

def process_file(filename)
  File.read(filename).strip.split("\n").map do |line|
    winner_string, your_string = line.split(": ")[1].split(" | ")
    {winners: winner_string.split.map(&:to_i), yours: your_string.split.map(&:to_i)}
  end
end

####

puts "Total scratch card points (test): #{sum_points_all_cards(process_file("day04-input-test.txt"))}"
puts "Total scratch card points (real): #{sum_points_all_cards(process_file("day04-input.txt"))}"

puts "Total scratch cards (test): #{play_actual_rules(process_file("day04-input-test.txt"))}"
puts "Total scratch cards (real): #{play_actual_rules(process_file("day04-input.txt"))}"
