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

def run_program(i_ptr_register, registers, instructions)
  i_ptr = 0

  max_iterations = 1000000
  num_iterations = 0
  original_reg_0 = registers[0]

  (16+(7*256)+16+(7*2) + 10 + 10000).times do |iteration|
    num_iterations = iteration

    before = registers

    registers[i_ptr_register] = i_ptr

    instruction = instructions[i_ptr]

    registers = send(instruction[0], instruction[1], instruction[2], instruction[3], registers)
 
    puts "ip=#{i_ptr} #{before.inspect} #{instruction.join(" ")} #{registers.inspect}"
   
    i_ptr = registers[i_ptr_register]
    
    i_ptr += 1

    break if i_ptr >= instructions.length
  end

  registers
end

################

def process_file(filename, num_samples=0)

  i_ptr = nil
  registers = [0,0,0,0,0,0]
  instructions = []

  File.read(filename).chomp.split("\n").each_with_index do |line, index|
    if index == 0
      i_ptr = line.split(" ")[1].to_i
      next
    end

    m = /(.+) ([\d]+) ([\d]+) ([\d]+)/.match(line)
    instructions << [m[1].to_sym, m[2].to_i, m[3].to_i, m[4].to_i]
  end

  0.upto(0) do |iteration|
    registers[0] = iteration
    run_program(i_ptr, registers, instructions)
  end
end

#############

process_file("day21-input.txt")
