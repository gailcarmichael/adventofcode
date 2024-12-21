class Computer
  def initialize(register_a, register_b, register_c)
    @register_a = register_a
    @register_b = register_b
    @register_c = register_c
  end

  # The value of a literal operand is the operand itself.
  # Combo operands 0 through 3 represent literal values 0 through 3.
  # Combo operand 4 represents the value of register A.
  # Combo operand 5 represents the value of register B.
  # Combo operand 6 represents the value of register C.
  # Combo operand 7 is reserved and will not appear in valid programs.

  def combo_operand_value(operand)
    case operand
    when 0..3 then operand
    when 4 then @register_a
    when 5 then @register_b
    when 6 then @register_c
    end
  end

  def to_s
    "a=#{@register_a}  b=#{@register_b}  c=#{@register_c}"
  end

  def adv(operand, output) # division with result in A
    @register_a = (@register_a / (2**combo_operand_value(operand))).floor.to_int
    @instruction_ptr += 2
  end

  def bxl(operand, output) # bitwise XOR
    @register_b = @register_b ^ operand
    @instruction_ptr += 2
  end

  def bst(operand, output) # operand mod 8
    @register_b = combo_operand_value(operand) % 8
    @instruction_ptr += 2
  end

  def jnz(operand, output) # jump if A is not zero
    if @register_a == 0
      @instruction_ptr += 2
    else
      @instruction_ptr = operand
    end
  end

  def bxc(operand, output) # bitwise XOR
    @register_b = @register_b ^ @register_c
    @instruction_ptr += 2
  end

  def out(operand, output) # output the result of operand mod 8
    output.push(combo_operand_value(operand) % 8)
    @instruction_ptr += 2
  end

  def bdv(operand, output) # division with result in B
    @register_b = (@register_a / (2**combo_operand_value(operand))).floor.to_int
    @instruction_ptr += 2
  end

  def cdv(operand, output) # division with result in C
    @register_c = (@register_a / (2**combo_operand_value(operand))).floor.to_int
    @instruction_ptr += 2
  end

  @@OPCODE_TO_METHOD = [:adv, :bxl, :bst, :jnz, :bxc, :out, :bdv, :cdv]

  def run_program(program)
    output = []
    @program = program
    @instruction_ptr = 0

    while @instruction_ptr < program.length
      send(@@OPCODE_TO_METHOD[@program[@instruction_ptr]], @program[@instruction_ptr+1], output)
    end

    output
  end
end

##################

###
# For the real input, each digit switches every 8**n)-1 values of register A
# This method only works for the real program right now. Maybe I'll generatlize
# it someday (haha).

def lowest_register_a(program)
  start = 3 * (8**(program.length-1)) +  # 3
          0 * (8**(program.length-2)) +  # 0, 7
          7 * (8**(program.length-3)) +  # 7
          4 * (8**(program.length-4)) +  # 4
          1 * (8**(program.length-5)) +  # 1
          0 * (8**(program.length-6)) +  # 0
          3 * (8**(program.length-7)) +  # 3
          2 * (8**(program.length-8)) +  # 2
          9 * (8**(program.length-9)) +  # 1, 9
          3 * (8**(program.length-10)) + # 3
          3 * (8**(program.length-11)) + # 3
          2 * (8**(program.length-12)) + # 2
          2 * (8**(program.length-13)) + # 2
          3 * (8**(program.length-14)) + #
          4 * (8**(program.length-15)) + #
          0 * (8**(program.length-16)) + #
          0

  num_iterations = 1

  curr_register_value = start

  1.upto(num_iterations) do
    computer = Computer.new(curr_register_value, 0, 0)
    output = computer.run_program(program)

    break if output.length > program.length

    puts "#{curr_register_value} \t #{output}"

    if program == output
      puts "Program output itself when register A set to #{curr_register_value}"
      return
    end
    curr_register_value += 1
  end
end

##################

# computer = Computer.new(729, 0, 0)
# program = [0,1,5,4,3,0]
# output = computer.run_program(program)
# puts computer
# puts "Program output (test): #{output}"

# computer = Computer.new(53437164, 0, 0)
# program = [2,4,1,7,7,5,4,1,1,4,5,5,0,3,3,0]
# output = computer.run_program(program)
# puts computer
# puts "Program output (real): #{output}"

lowest_register_a([2,4,1,7,7,5,4,1,1,4,5,5,0,3,3,0])
