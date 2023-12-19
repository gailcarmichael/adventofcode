CARD_RANKS = ['A', 'K', 'Q', 'J', 'T', '9', '8', '7', '6', '5', '4', '3', '2']
CARD_RANKS_PART_2 = ['A', 'K', 'Q', 'T', '9', '8', '7', '6', '5', '4', '3', '2', 'J']
HAND_RANKS = [:five_kind, :four_kind, :full_house, :three_kind, :two_pair, :one_pair, :high_card]

def hand_type(hand)
  card_counts = Hash.new(0)
  hand.each {|card| card_counts[card] += 1}

  case card_counts.size
  when 1
    return :five_kind
  when 2
    return :full_house if card_counts.any?{|card, count| count == 3}
    return :four_kind
  when 3
    return :three_kind if card_counts.any?{|card, count| count == 3}
    return :two_pair
  when 4
    return :one_pair
  else
    return :high_card
  end
end

def hand_type_2(hand)
  card_counts = Hash.new(0)
  hand.each {|card| card_counts[card] += 1}

  normal_hand_type = hand_type(hand)
  case normal_hand_type
  when :five_kind
    return :five_kind
  when :four_kind
    return :five_kind if card_counts.any?{|card, count| card == 'J'}
  when :full_house
    return :five_kind if card_counts.any?{|card, count| card == 'J'}
  when :three_kind
    return :four_kind if card_counts.any?{|card, count| card == 'J'}
  when :two_pair
    return :four_kind if card_counts.any?{|card, count| card == 'J' and count == 2}
    return :full_house if card_counts.any?{|card, count| card == 'J' and count == 1}
  when :one_pair
    return :three_kind if card_counts.any?{|card, count| card == 'J'}
  when :high_card
    return :one_pair if card_counts.any?{|card, count| card == 'J'}
  end

  return normal_hand_type
end

def compare_cards(card1, card2, part2=false)
  card_ranks = part2 ? CARD_RANKS_PART_2 : CARD_RANKS
  rank1 = card_ranks.index(card1)
  rank2 = card_ranks.index(card2)
  rank1 - rank2
end

def compare_hands(hand1, hand2, part2=false)
  rank1 = HAND_RANKS.index(part2 ? hand_type_2(hand1) : hand_type(hand1))
  rank2 = HAND_RANKS.index(part2 ? hand_type_2(hand2) : hand_type(hand2))

  if (rank1 == rank2)
    hand1.each_with_index do |card1, index|
      cards_compared = compare_cards(card1, hand2[index], part2)
      return cards_compared if cards_compared != 0
    end
    return 0
  else
    return rank1 - rank2
  end
end

def rank_hands_and_bids(hands_and_bids, part2=false)
  hands_and_bids.sort do |hand_and_bid1, hand_and_bid2|
    compare_hands(hand_and_bid1[0], hand_and_bid2[0], part2)
  end.reverse
end

def total_winnings(hand_and_bid_list, part2=false)
  winnings = 0
  rank_hands_and_bids(hand_and_bid_list, part2).each_with_index do |hand_and_bid, index|
    winnings += hand_and_bid[1] * (index+1)
  end
  winnings
end

####

def process_file(filename)
  File.read(filename).strip.split("\n").map do |line|
    hand_and_bid = line.split
    [hand_and_bid[0].split(""), hand_and_bid[1].to_i]
  end
end

####

puts "Total winnings (test): #{total_winnings(process_file("day07-input-test.txt"))}"
puts "Total winnings (real): #{total_winnings(process_file("day07-input.txt"))}"

puts "\n"

puts "Total winnings part 2 (test): #{total_winnings(process_file("day07-input-test.txt"), part2=true)}"
puts "Total winnings part 2 (real): #{total_winnings(process_file("day07-input.txt"), part2=true)}"
