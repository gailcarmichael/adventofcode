input = File.read("day18-input.txt").strip

class Program
  attr_accessor :numTimesSent

  def initialize(instructionList, programNumber)
    @instructionList = instructionList

    @registers = Hash.new(0)
    @programNumber = programNumber
    @registers['p'] = programNumber

    @dataQueue = []
    @numTimesSent = 0

    @currInstructionIndex = 0
  end

  def getValue(registers, arg)
    if arg =~ /[[:digit:]]/
      return arg.to_i
    else
      return registers[arg]
    end
  end

  def sendDataTo(data, otherProgram)
    if otherProgram != nil
      otherProgram.queueData(data) 
      @numTimesSent += 1
    end
  end

  def queueData(data)
    @dataQueue.push(data)
  end

  def receiveDataInto(register)
    if @dataQueue.length > 0
      @registers[register] = @dataQueue[0]
      @dataQueue.delete_at(0)
      return true
    else
      return false
    end
  end

  def processNextInstruction(otherProgram=nil)
    puts "prog#{@programNumber} index=#{@currInstructionIndex} #{@instructionList[@currInstructionIndex]}"

    parts = @instructionList[@currInstructionIndex].split(" ")
    status = :normal

    case parts[0]
    when 'snd'
      sendDataTo(getValue(@registers, parts[1]), otherProgram)
    when 'set'
      @registers[parts[1]] = getValue(@registers, parts[2])
    when 'add'
      @registers[parts[1]] += getValue(@registers, parts[2])
    when 'mul'
      @registers[parts[1]] *= getValue(@registers, parts[2])
    when 'mod'
      @registers[parts[1]] %= getValue(@registers, parts[2])
    when 'rcv'
      status = :noDataQueued if !receiveDataInto(parts[1])
    when 'jgz'
      if getValue(@registers, parts[1]) > 0
        @currInstructionIndex += getValue(@registers, parts[2]) - 1
      end
    end
    
    @currInstructionIndex += 1 if status == :normal

    p @registers
    p @dataQueue

    status = :programDone if @currInstructionIndex < 0 ||
                             @currInstructionIndex >= @instructionList.length

    return status
  end
end

instructionList = input.split("\n")
prog0 = Program.new(instructionList, 0)
prog1 = Program.new(instructionList, 1)

loop do
  result1 = prog0.processNextInstruction(prog1)
  result2 = prog1.processNextInstruction(prog0)
  puts "#{result1} #{result2}\n\n"
  break if result1 == :programDone || result2 == :programDone
  break if result1 == :noDataQueued && result2 == :noDataQueued
end

puts "Program 1 sent #{prog1.numTimesSent} times"
