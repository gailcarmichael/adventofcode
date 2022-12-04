class SectionRange
    attr_reader :min
    attr_reader :max

    def initialize(min, max)
        @min = min
        @max = max
    end

    def to_s
        "#{@min}-#{@max}"
    end

    def fully_contained_in?(other_range)
        @min >= other_range.min && @max <= other_range.max
    end

    def overlaps?(other_range)
        self.fully_contained_in?(other_range) ||
        other_range.fully_contained_in?(self) ||
        (@max >= other_range.min && @min <= other_range.max)
    end
end


def count_pairs_fully_contained(assignment_pairs)
    assignment_pairs.filter do |assignment_pair|
        assignment_pair[0].fully_contained_in?(assignment_pair[1]) ||
        assignment_pair[1].fully_contained_in?(assignment_pair[0])
    end.count
end

def count_pairs_overlapping(assignment_pairs)
    assignment_pairs.filter do |assignment_pair|
        assignment_pair[0].overlaps?(assignment_pair[1])
    end.count
end


def process_file(filename)
    pair_list = Array.new
    File.read(filename).strip.split("\n").each do |line|
        ranges = line.split(",").map do |range|
            end_points = range.split("-")
            SectionRange.new(end_points[0].to_i, end_points[1].to_i)
        end
        pair_list.push(ranges)
    end
    pair_list
end

assignment_pairs_test = process_file("day04-input-test.txt")
assignment_pairs_real = process_file("day04-input.txt")

puts "Part 1 test: #{count_pairs_fully_contained(assignment_pairs_test)}"
puts "Part 1 real: #{count_pairs_fully_contained(assignment_pairs_real)}"

puts "Part 2 test: #{count_pairs_overlapping(assignment_pairs_test)}"
puts "Part 2 real: #{count_pairs_overlapping(assignment_pairs_real)}"