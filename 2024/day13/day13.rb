class Equation
  attr_reader :a_term
  attr_reader :b_term
  attr_reader :constant

  def initialize(a_term, b_term, constant)
    @a_term = a_term
    @b_term = b_term
    @constant = constant
  end

  def to_s
    "A•#{@a_term} + B•#{@b_term} = #{@constant}"
  end

  def solve_as_system(other_eq)
    den = (b_term * other_eq.a_term) - (other_eq.b_term * a_term)
    num = (b_term * other_eq.constant) - (other_eq.b_term * constant)
    a = num/den
    b = (constant - (a * a_term)) / b_term

    if (other_eq.a_term * a + other_eq.b_term * b) == other_eq.constant
      [a, b]
    else
      :none
    end
  end
end

def cost_of_tokens(eq1, eq2)
  result1 = eq1.solve_as_system(eq2)
  if (result1 != :none)
    result1 = result1[0]*3 + result1[1]
  end

  result2 = eq2.solve_as_system(eq1)
  if (result2 != :none)
    result2 = result2[0]*3 + result2[1]
  end

  if result1 != :none && result2 != :none
    [result1, result2].min
  else
    0
  end
end

def total_cost_of_tokens(systems)
  systems.map do |system|
    cost = cost_of_tokens(system[0], system[1])
    cost = 0 if (cost == :none)
    cost
  end.sum
end

################

def process_file(filename, add_error=false)
  systems = Array.new
  File.read(filename).strip.split("\n\n").each do |system|
    matchData = /Button A: X\+(\d+), Y\+(\d+)\nButton B: X\+(\d+), Y\+(\d+)\nPrize: X=(\d+), Y=(\d+)/.match(system)

    constant1 = matchData[5].to_i
    constant1 += 10000000000000 if add_error

    constant2 = matchData[6].to_i
    constant2 += 10000000000000 if add_error

    eq1 = Equation.new(matchData[1].to_i, matchData[3].to_i, constant1)
    eq2 = Equation.new(matchData[2].to_i, matchData[4].to_i, constant2)
    systems.push([eq1, eq2])
  end
  systems
end

puts
systems = process_file("day13-input-test.txt")
puts "Cost of tokens (test): #{total_cost_of_tokens(systems)}"
systems = process_file("day13-input-test.txt", true)
puts "Cost of tokens with error (test): #{total_cost_of_tokens(systems)}"

puts
systems = process_file("day13-input.txt")
puts "Cost of tokens (real): #{total_cost_of_tokens(systems)}"
systems = process_file("day13-input.txt", true)
puts "Cost of tokens with error (real): #{total_cost_of_tokens(systems)}"
