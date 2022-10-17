reg1_values = []

reg0 = 5363733
reg1 = 0

iterations = 0

loop do
  iterations += 1

  reg2 = reg1 | 65536
  reg1 = 8725355
  loop do
    reg5 = reg2 & 255

    reg1 += reg5
    reg1 &= 0b111111111111111111111111
    reg1 *= 65899
    reg1 &= 0b111111111111111111111111

    if reg2 < 256
      break
    end

    reg2 = reg2/256
  end

  if reg1_values.include? reg1
    # p reg1
    break
  else
    reg1_values << reg1
  end

  if reg1 == reg0
    p iterations
    break
  end
end
