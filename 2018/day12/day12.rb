class PotRow

  def initialize(initial_state)
    @pots_hash = Hash.new('.')
    initial_state.each_with_index {|char, index| @pots_hash[index] = char}

    @rules = Hash.new('.')
  end

  def add_rule(llcrr, result)
    @rules[llcrr] = result
  end

  def run_simulation(rounds)
    previous_sum = 0
    previous_previous_increase = -1
    previous_increase = 0

    rounds.times do |round|
      if previous_previous_increase != previous_increase
        next_pots_hash = Hash.new('.')
        min_index = @pots_hash.keys.min
        max_index = @pots_hash.keys.max

        (min_index-2).upto(max_index+1) {|index| apply_rule(index, next_pots_hash)}
        
        @pots_hash = next_pots_hash

        curr_sum = sum_of_pot_indexes

        curr_increase = curr_sum - previous_sum
        
        previous_previous_increase = previous_increase
        previous_increase = curr_increase        
        previous_sum = curr_sum
      else
        previous_sum += (rounds-round)*previous_increase
        break
      end
    end

    #sum_of_pot_indexes
    previous_sum
  end

  def sum_of_pot_indexes
    sum = 0
    @pots_hash.each {|index, char| sum += index if char == '#'}
    sum
  end

  def num_pots
    @pots_hash.length
  end

  def to_s
    @pots_hash.values.join
  end

  private

  def apply_rule(pot_index, new_hash)
    result = find_result(pot_index)
    new_hash[pot_index] = result if result == '#'
  end

  def find_result(pot_index)
    llcrr = pots_slice((pot_index-2),(pot_index+2))

    @rules[llcrr]
  end

  def pots_slice(start_index, end_index)
    slice = []
    start_index.upto(end_index) {|index| slice << @pots_hash[index]}
    slice.join
  end

end

###

def process_file(filename, arg=20)
  lines = File.read(filename).strip.split("\n")

  initial_state = /initial state: (.*)/.match(lines.shift)[1]
  pots = PotRow.new(initial_state.split(''))

  lines.shift # get rid of empty line

  lines.each do |line|
    m = /(.....) => (.)/.match(line)
    pots.add_rule(m[1], m[2])
  end

  puts pots.run_simulation(arg)
end

process_file("day12-input-test.txt")
process_file("day12-input.txt", 50000000000)
