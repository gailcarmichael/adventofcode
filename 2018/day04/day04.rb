require 'date'

###

class Record
  include Comparable

  attr_reader :date

  def initialize(date, event_string)
    @date = date
    @event_string = event_string
  end

  def <=>(other_record)
    date <=> other_record.date
  end

  def to_s
    date.to_s + " " + @event_string
  end

  def begins_shift_event?
    @event_string.include?("begins shift")
  end

  def falling_asleep_event?
    @event_string.include?("falls asleep")
  end

  def waking_event?
    @event_string.include?("wakes up")
  end

  def guard_id
    return /Guard #([\d]+) begins shift/.match(@event_string)[1].to_i if begins_shift_event?
    nil
  end
end

###

class SleepyGuardFinder
  def initialize
    @records = []
  end

  def add_record(record)
    @records << record
    @records.sort!
  end

  def to_s
    @records.reduce("") { |so_far, record| so_far + record.to_s + "\n"}
  end

  def guard_sleep_chart
    guard_chart = Hash.new { |h, k| h[k] = Hash.new(0) }

    last_guard_id = nil
    sleep_time = nil
    @records.each do |record|
      if record.begins_shift_event?
        last_guard_id = record.guard_id
      elsif record.falling_asleep_event?
        sleep_time = record.date
      elsif record.waking_event?
        diff = (record.date - sleep_time)
        total_minutes = (diff * 24 * 60).to_i

        (0..total_minutes-1).each do |minute|
          guard_chart[last_guard_id][(sleep_time.min + minute) % 60] += 1
        end
      end
    end

    guard_chart
  end

  def first_strategy
    guard_chart = guard_sleep_chart
    max_id = guard_chart.max_by {|guard_id, minute_hash| minute_hash.values.reduce(:+)}[0]
    max_minute = guard_chart[max_id].max_by {|minute, value| value}[0]
    max_id * max_minute
  end

  def second_strategy
    guard_chart = guard_sleep_chart
    max_id = guard_chart.max_by {|guard_id, minute_hash| minute_hash.values.max}[0]
    max_minute = guard_chart[max_id].max_by {|minute, value| value}[0]
    max_id * max_minute
  end
end

###

def process_file(filename, message)
  sleepy_guard_finder = SleepyGuardFinder.new

  File.read(filename).strip.split("\n").each do |line|
    m = /\[(.*)\] (.*)/.match(line)
    date_time = DateTime.strptime(m[1].gsub(/\s+/, "T"), '%Y-%m-%dT%R')
    event_string = m[2]
    sleepy_guard_finder.add_record(Record.new(date_time, event_string))
  end
  
  sleepy_guard_finder.public_send(message)
end

puts "Test part 1: #{process_file("day04-input-test.txt", :first_strategy)}"
puts "Real part 1: #{process_file("day04-input.txt", :first_strategy)}"

puts "Test part 2: #{process_file("day04-input-test.txt", :second_strategy)}"
puts "Real part 2: #{process_file("day04-input.txt", :second_strategy)}"
