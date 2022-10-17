class Simulation
  def initialize
    @lanternfish = Hash.new(0)
  end

  def add_lanternfish(initial_value)
    @lanternfish[initial_value] += 1
  end

  def run(num_days)
    (1..num_days).each do |day|
      new_day
    end
  end

  def num_lanternfish
    @lanternfish.values.reduce(&:+)
  end

  private
  
  def new_day
    new_fish_hash = Hash.new(0)

    new_fish_hash[8] = @lanternfish[0]
    new_fish_hash[7] = @lanternfish[8]
    new_fish_hash[6] = @lanternfish[0] + @lanternfish[7]
  
    (1..6).each do |timer_value|
      new_fish_hash[timer_value-1] = @lanternfish[timer_value]
    end

    @lanternfish = new_fish_hash
  end
end

################################################################

def process_file(filename)
  sim = Simulation.new
  File.read(filename, chomp: true).split(",").each {|n| sim.add_lanternfish(n.to_i)}
  sim
end

################################################################

sim = process_file("day06-input-test.txt")
sim.run(80)
puts "Test number of fish after 80 days: #{sim.num_lanternfish}"

sim = process_file("day06-input.txt")
sim.run(80)
puts "Real number of fish after 80 days: #{sim.num_lanternfish}"

sim = process_file("day06-input.txt")
sim.run(256)
puts "Real number of fish after 256 days: #{sim.num_lanternfish}"