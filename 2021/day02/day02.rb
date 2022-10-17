def process_commands(position, commands)
  commands.each do |command|
    case command[:direction]
    when "forward"
      position[:x] += command[:amount]
    when "down"
      position[:depth] += command[:amount]
    when "up"
      position[:depth] -= command[:amount]
    end
  end
  position
end

def process_commands_alternate(position, commands)
  commands.each do |command|
    case command[:direction]
    when "forward"
      position[:x] += command[:amount]
      position[:depth] += (position[:aim] * command[:amount])
    when "down"
      position[:aim] += command[:amount]
    when "up"
      position[:aim] -= command[:amount]
    end
  end
  position
end

def process_file(filename)
  commands = Array.new
  File.read(filename).strip.split("\n").each do |line|
    line_parts = line.split(" ")
    commands.push({direction: line_parts[0], amount: line_parts[1].to_i})
  end
  commands
end

initial_position = {x: 0, depth: 0}
initial_position_alternate = {x: 0, depth: 0, aim: 0}

test_commands = process_file("day02-input-test.txt")
commands = process_file("day02-input.txt")

puts "\nPart 1 test"
final_position = process_commands(initial_position, test_commands)
p final_position
p final_position[:depth] * final_position[:x]

puts "\nPart 1 real"
final_position = process_commands(initial_position, commands)
p final_position
p final_position[:depth] * final_position[:x]

puts "\nPart 2 test"
final_position = process_commands_alternate(initial_position_alternate, test_commands)
p final_position
p final_position[:depth] * final_position[:x]

puts "\nPart 2 real"
final_position = process_commands_alternate(initial_position_alternate, commands)
p final_position
p final_position[:depth] * final_position[:x]