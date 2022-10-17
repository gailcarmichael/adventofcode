require 'set'

def addr(a, b, c, registers)
  registers = registers.clone
  registers[c] = registers[a] + registers[b]
  registers
end

def addi(a, b, c, registers)
  registers = registers.clone
  registers[c] = registers[a] + b
  registers
end

def mulr(a, b, c, registers)
  registers = registers.clone
  registers[c] = registers[a] * registers[b]
  registers
end

def muli(a, b, c, registers)
  registers = registers.clone
  registers[c] = registers[a] * b
  registers
end

def banr(a, b, c, registers)
  registers = registers.clone
  registers[c] = registers[a] & registers[b]
  registers
end

def bani(a, b, c, registers)
  registers = registers.clone
  registers[c] = registers[a] & b
  registers
end

def borr(a, b, c, registers)
  registers = registers.clone
  registers[c] = registers[a] | registers[b]
  registers
end

def bori(a, b, c, registers)
  registers = registers.clone
  registers[c] = registers[a] | b
  registers
end

def setr(a, b, c, registers)
  registers = registers.clone
  registers[c] = registers[a]
  registers
end

def seti(a, b, c, registers)
  registers = registers.clone
  registers[c] = a
  registers
end

def gtir(a, b, c, registers)
  registers = registers.clone
  registers[c] = a > registers[b] ? 1 : 0
  registers
end

def gtri(a, b, c, registers)
  registers = registers.clone
  registers[c] = registers[a] > b ? 1 : 0
  registers
end

def gtrr(a, b, c, registers)
  registers = registers.clone
  registers[c] = registers[a] > registers[b] ? 1 : 0
  registers
end

def eqir(a, b, c, registers)
  registers = registers.clone
  registers[c] = a == registers[b] ? 1 : 0
  registers
end

def eqri(a, b, c, registers)
  registers = registers.clone
  registers[c] = registers[a] == b ? 1 : 0
  registers
end

def eqrr(a, b, c, registers)
  registers = registers.clone
  registers[c] = registers[a] == registers[b] ? 1 : 0
  registers
end

################

def check_if_op_code_works(function, instruction, before, after)
  send(function, instruction[1], instruction[2], instruction[3], before) == after
end

################

def process_file(filename, num_samples=0)

  sample_to_functions_that_work = Hash.new{|h,k| h[k] = Array.new}
  op_code_to_samples_that_work = Hash.new{|h,k| h[k] = Array.new}
  op_code_to_possible_functions = Hash.new{|h,k| h[k] = Set.new}

  op_functions = [:addr, :addi,
                  :mulr, :muli,
                  :banr, :bani,
                  :borr, :bori,
                  :setr, :seti,
                  :gtir, :gtri, :gtrr,
                  :eqir, :eqri, :eqrr]

  #############

  lines = File.read(filename).chomp.split("\n")
  samples = Hash.new

  num_samples.times.each do |sample_num|
    m = /Before: \[(\d), (\d), (\d), (\d)\]/.match(lines[sample_num*4])
    before = [m[1], m[2], m[3], m[4]].map! {|item| item.to_i}

    m = /([\d]+) ([\d]+) ([\d]+) ([\d]+)/.match(lines[sample_num*4+1])
    instruction = [m[1], m[2], m[3], m[4]].map! {|item| item.to_i}

    m = /After:  \[(\d), (\d), (\d), (\d)\]/.match(lines[sample_num*4+2])
    after = [m[1], m[2], m[3], m[4]].map! {|item| item.to_i}

    samples[sample_num] = [instruction, before, after]

    op_functions.each do |function|
      if check_if_op_code_works(function, instruction, before, after)
        sample_to_functions_that_work[sample_num] << function
        op_code_to_samples_that_work[instruction[0]] << sample_num
        op_code_to_possible_functions[instruction[0]] << function
      end
    end
  end

  #############

  three_or_more = sample_to_functions_that_work.select{|sample_num, op_code_list| op_code_list.length >= 3}
  puts "Number of samples that behave like >=3 op codes: #{three_or_more.length}\n\n"

  #############

  op_code_to_possible_functions = op_code_to_possible_functions.sort

  op_code_to_possible_functions.each {|op_code, function_list| puts "#{op_code}: #{function_list.to_a}"}

  #############

  # From inspection, we know:
  # => 0 must be :mulr since it's the only place it appears
  # => 1 must be :eqri since it only appears in 7 and 11 (assigned) and here
  # => 2 must be :setr since it only appears in 7 and 9 (both assigned) and here
  # => 3 must be :eqrr since it only appears in 0 and 1 (assigned) and here
  # => 4 must be :gtrr
  # => 5 must be :muli
  # => 6 must be :borr
  # => 7 must be :bani since it only appears in 9 (now assigned) and here
  # => 8 must be :addr
  # => 9 must be :banr since it's the only place it appears
  # => 10 must be :eqir since it only appears in 1, 7, and 11 (assigned) and here
  # => 11 must be :gtir since it only appears in 2, 7, and 9 (all assigned) and here
  # => 12 must be :addi
  # => 13 must be :gtri
  # => 14 must be :seti
  # => 15 must be :bori

  #############

  known_mapping = [:mulr, :eqri, :setr, :eqrr, :gtrr, :muli, :borr, :bani,
                   :addr, :banr, :eqir, :gtir, :addi, :gtri, :seti, :bori]

  registers = [0,0,0,0]
  (num_samples*4+2).upto(lines.length-1) do |line_num|
    m = /([\d]+) ([\d]+) ([\d]+) ([\d]+)/.match(lines[line_num])
    instruction = [m[1], m[2], m[3], m[4]].map! {|item| item.to_i}

    registers = send(known_mapping[instruction[0]], instruction[1], instruction[2], instruction[3], registers)
  end

  p registers

end

#############

# process_file("day16-input-test.txt", 1)
process_file("day16-input.txt", 812)
