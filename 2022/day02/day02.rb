OPPONENT_PICKS = {'A' => :rock, 'B' => :paper, 'C' => :scissors}
YOUR_PICKS     = {'X' => :rock, 'Y' => :paper, 'Z' => :scissors}

TO_WIN = {rock: :paper, paper: :scissors, scissors: :rock}
TO_LOSE = {rock: :scissors, paper: :rock, scissors: :paper}
TO_DRAW = {rock: :rock, paper: :paper, scissors: :scissors}

SCORES = {rock: 1, paper: 2, scissors: 3}

def did_you_win(opp_pick, your_pick)
    (opp_pick == :rock && your_pick == :paper) ||
    (opp_pick == :paper && your_pick == :scissors) ||
    (opp_pick == :scissors && your_pick == :rock)
end

def did_you_draw(opp_pick, your_pick)
    opp_pick == your_pick
end

def score_for_strategy_guide(rounds)
    rounds.map do |round|
        score = SCORES[round[1]]
        if did_you_win(round[0], round[1])
            score += 6
        elsif did_you_draw(round[0], round[1])
            score += 3
        end
        score
    end.inject(:+)
end

def score_for_strategy_guide_2(rounds)
    rounds.map do |round|
        # We already translated everything to rock, paper, scissors;
        # could have converted to lose/win/draw but not worth it for
        # this particular problem

        case round[1]
        when :rock # you lose
            SCORES[TO_LOSE[round[0]]]
        when :paper # you draw
            SCORES[TO_DRAW[round[0]]] + 3
        when :scissors # you win
            SCORES[TO_WIN[round[0]]] + 6
        end
        
    end.inject(:+)
end


def process_file(filename)
    File.read(filename).strip.split("\n").map do |line|
        round_picks = line.split
        [OPPONENT_PICKS[round_picks[0]], YOUR_PICKS[round_picks[1]]]
    end
end

rounds_test = process_file("day02-input-test.txt")
rounds_real = process_file("day02-input.txt")

puts "Test part 1: #{score_for_strategy_guide(rounds_test)}"
puts "Real part 1: #{score_for_strategy_guide(rounds_real)}"

puts "Test part 2: #{score_for_strategy_guide_2(rounds_test)}"
puts "Real part 2: #{score_for_strategy_guide_2(rounds_real)}"