input = File.read("day08-input.txt").strip

registers = Hash.new(0)
allValuesHeld = [0]

input.split("\n").each do |instruction|
  matchData = /(\w+) (inc|dec) (-?\d+) if (.+)/.match(instruction)

  register = matchData[1]
  action = matchData[2]
  amount = matchData[3].to_i
  condition = matchData[4]

  condition.sub!(/\w+/) {|s| "registers['#{s}']"}

  if eval(condition)
    amount *= -1 if action == "dec"
    registers[register] += amount
    allValuesHeld.push(registers[register])
  end
end

puts "The max value in the registers is #{registers.values.max}"
puts "The highest value ever held is #{allValuesHeld.max}"
