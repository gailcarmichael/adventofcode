class SleighInstructions
  def initialize
    @nodes = Hash.new { |h, k| h[k] = Hash.new }
  end

  def add_instruction(finish_first, then_do_this)
    @nodes[finish_first][:children] ||= Array.new
    @nodes[finish_first][:children] << then_do_this

    @nodes[then_do_this][:parents] ||= Array.new
    @nodes[then_do_this][:parents] << finish_first
  end

  def first_steps
    roots = @nodes.select {|step, info| info[:parents] == nil}
    roots.keys.sort!
  end

  def available_steps
    available = @nodes.select do |step, info| 
      if !info[:done]
        if info[:parents]
          info[:parents].all? {|parent| @nodes[parent][:done]} # not done, parents are all done
        else
          true # not done, has no parents
        end
      else
        false # done
      end
    end
    available.keys.sort
  end

  def timed_available_steps
    # additionally check if the "available" steps are not already in progress
    available_steps.select {|step| @nodes[step][:seconds_in] == nil || @nodes[step][:seconds_in] <= 0}
  end

  def instruction_order
    first = first_steps[0]
    
    steps = [first]
    @nodes[first][:done] = true

    loop do
      next_steps = available_steps
      break if next_steps.empty?

      steps << next_steps.first
      @nodes[steps.last][:done] = true
    end

    steps.join('')
  end

  def timed_instruction_order(seconds_offset, num_workers)
    worker_current_step = Array.new(num_workers)

    current_second = 0
    final_steps = []
    loop do
      # Check for workers that are done from the previous tick
      worker_current_step.each_with_index do |step, index|
        if step && timed_step_done?(step, seconds_offset)
          worker_current_step[index] = nil
          @nodes[step][:seconds_in] = 0
          @nodes[step][:done] = true
          final_steps << step
        end
      end

      next_steps = timed_available_steps

      worker_current_step.each_with_index do |step, index|
        if step
          # update time spent on this step
          @nodes[step][:seconds_in] += 1
        elsif !next_steps.empty?
          # worker is available to start working, if there's a step they can do
          worker_current_step[index] = next_steps.shift
          @nodes[worker_current_step[index]][:seconds_in] = 1
        end
      end

      # End the process if everything is done
      break if final_steps.length == @nodes.length

      # Otherwise, the clock ticks one second
      current_second += 1
    end

    current_second
  end

  private def timed_step_done?(step, seconds_offset)
    @nodes[step][:seconds_in] >= (step.ord - 'A'.ord + 1 + seconds_offset)
  end
end

###

def process_file(filename, message, args=nil)
  instructions = SleighInstructions.new
  
  File.read(filename).strip.split("\n").each do |line|
    m = /Step (.) must be finished before step (.) can begin./.match(line)
    instructions.add_instruction(m[1], m[2])
  end

  if args
    instructions.public_send(message, args[0], args[1])
  else
    instructions.public_send(message)
  end
end

puts "Test part 1: #{process_file("day07-input-test.txt", :instruction_order)}"
puts "Real part 1: #{process_file("day07-input.txt", :instruction_order)}"

puts "Test part 2: #{process_file("day07-input-test.txt", :timed_instruction_order, [0, 2])}"
puts "Real part 2: #{process_file("day07-input.txt", :timed_instruction_order, [60, 5])}"
