def new_recipe_scores(score1, score2)
  sum = (score1+score2)
  if sum >= 10
    [sum/10, sum % 10]
  else
    [sum % 10]
  end
end

def next_ten_recipes(start_after)
  start_after = start_after.to_i
  num_scores_needed = start_after + 10
  scores = [3, 7]
  
  elf1_index = 0
  elf2_index = 1

  loop do
    new_recipe_scores(scores[elf1_index], scores[elf2_index])
        .each {|score| scores << score}

    elf1_index = (elf1_index + scores[elf1_index] + 1) % scores.length
    elf2_index = (elf2_index + scores[elf2_index] + 1) % scores.length
    
    break if scores.length >= num_scores_needed
  end

  scores = scores[0..num_scores_needed-1]

  p scores.length
  p scores[start_after-5..-1]
  puts "#{elf1_index}, #{elf2_index}"

  scores[start_after..-1].join.to_i
end

def reverse_lookup(recipe_sequence)
  scores = [3, 7]
  
  n = recipe_sequence.length

  elf1_index = 0
  elf2_index = 1

  loop do
    new_scores = new_recipe_scores(scores[elf1_index], scores[elf2_index])
    found_it = false

    new_scores.each do |score| 
      scores << score
      
      last_n = []
      if scores.length >= n
        (scores.length-n).upto(scores.length-1) {|index| last_n << scores[index]}
      end
      last_n = last_n.join

      if last_n == recipe_sequence
        found_it = (last_n == recipe_sequence)
        break
      end
    end

    break if found_it

    elf1_index = (elf1_index + scores[elf1_index] + 1) % scores.length
    elf2_index = (elf2_index + scores[elf2_index] + 1) % scores.length
  end

  scores.length-n
end

p reverse_lookup('51589')
p reverse_lookup('01245')
p reverse_lookup('92510')
p reverse_lookup('59414')
p reverse_lookup('891')
p reverse_lookup('825401')
