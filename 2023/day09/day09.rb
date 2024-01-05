def sequence_of_differences(sequence)
  new_sequence = []
  sequence.each_cons(2) do |n1, n2|
    new_sequence.push(n2-n1)
  end
  new_sequence
end

def produce_sequences_of_differences_until_zeros(sequence)
  seqs_of_diffs = [sequence]
  while (!seqs_of_diffs.last.all?(0))
    seqs_of_diffs.push(sequence_of_differences(seqs_of_diffs.last))
  end
  seqs_of_diffs
end

def compute_next_value(sequence)
  extrapolated_values = [0]
  produce_sequences_of_differences_until_zeros(sequence).reverse.each_cons(2) do |s1, s2|
    extrapolated_values.push(s2.last + extrapolated_values.last)
  end
  extrapolated_values.last
end

def compute_prev_value(sequence)
  extrapolated_values = [0]
  produce_sequences_of_differences_until_zeros(sequence).reverse.each_cons(2) do |s1, s2|
    extrapolated_values.push(s2.first - extrapolated_values.last)
  end
  extrapolated_values.last
end

def sum_of_next_values(sequences)
  sequences.sum do |sequence|
    compute_next_value(sequence)
  end
end

def sum_of_prev_values(sequences)
  sequences.sum do |sequence|
    compute_prev_value(sequence)
  end
end

###

def process_file(filename)
  File.read(filename).strip.split("\n").map do |line|
    line.split.map(&:to_i)
  end
end

###

puts "Sum of next extrapolated values (test): #{sum_of_next_values(process_file("day09-input-test.txt"))}"
puts "Sum of next extrapolated values (real): #{sum_of_next_values(process_file("day09-input.txt"))}"

puts "Sum of prev extrapolated values (test): #{sum_of_prev_values(process_file("day09-input-test.txt"))}"
puts "Sum of prev extrapolated values (real): #{sum_of_prev_values(process_file("day09-input.txt"))}"
