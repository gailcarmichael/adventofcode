class Almanac
  attr_reader :seeds, :range_mappings

  def initialize(seeds, seeds_in_ranges=false)
    @seeds = Array.new
    if seeds_in_ranges
      seeds.each_slice(2) do |start, length|
        @seeds.push (start..(start+length-1))
      end
    else
      seeds.each do |seed|
        @seeds.push (seed..seed)
      end
    end

    @range_mappings = Hash.new
  end

  def all_seeds
    @seeds.inject([]) {|so_far, next_range| so_far + next_range.to_a}
  end

  def seed_valid?(candidate)
    @seeds.any? {|range| range.include? candidate}
  end

  def add_range_mapping(category, source_start, destination_start, range_length)
    @range_mappings[category] ||= Array.new
    @range_mappings[category].push(RangeMapping.new(
      category.split("-")[0], category.split("-")[1],
      source_start, destination_start,
      range_length
    ))
  end

  def sort_range_mappings_per_category_by_dest
    @range_mappings.each do |cat, ranges|
      ranges.sort! do |range1, range2|
        if range1.dest_range == range2.dest_range
          0
        elsif range1.dest_range.end < range2.dest_range.begin
          -1
        else
          1
        end
      end
    end
  end

  def range_mappings_for_source(source_cat)
    matches = @range_mappings.select {|cat, ranges| cat.split("-")[0] == source_cat}
    if matches
      matches.values.first
    else
      nil
    end
  end

  def range_mappings_for_dest(dest_cat)
    matches = @range_mappings.select {|cat, ranges| cat.split("-")[1] == dest_cat}
    if matches
      matches.values.first
    else
      nil
    end
  end

  def map_category_to_category(from_cat, from_val, to_cat)
    curr_cat = from_cat
    curr_val = from_val
    while (curr_cat && curr_cat != to_cat)
      range_mappings = range_mappings_for_source(curr_cat)
      range_mappings.each do |range_mapping|
        result = range_mapping.lookup(curr_val)
        if result != nil
          curr_val = result
          break
        end
      end
      curr_cat = range_mappings.first.destination
    end
    curr_val
  end

  def reverse_map_location_to_seed(location)
    curr_cat = 0
    curr_val = location
    @categories ||= ["humidity-location", "temperature-humidity", "light-temperature", "water-light", "fertilizer-water", "soil-fertilizer", "seed-soil"]
    while (curr_cat < @categories.size)
      @range_mappings[@categories[curr_cat]].each do |range_mapping|
        result = range_mapping.reverse_lookup(curr_val)
        if result
          curr_val = result
          break
        end
      end
      curr_cat += 1
    end
    curr_val # this is a seed value that can be used to check for validity
  end

  def find_smallest_location_with_valid_seed(start_at=0)
    curr_location = start_at
    seed = nil
    while seed == nil
      candidate = reverse_map_location_to_seed(curr_location)
      if seed_valid?(candidate)
        seed = candidate
        break
      end
      curr_location += 1
    end
    curr_location
  end

end

class RangeMapping
  attr_reader :source, :destination, :source_range, :dest_range

  def initialize(source, destination, source_start, destination_start, range_length)
    @source = source
    @destination = destination
    @source_range = (source_start..(source_start + range_length - 1))
    @dest_range = (destination_start..(destination_start + range_length - 1))
  end

  def lookup(source_num)
    if @source_range.include?(source_num)
      @dest_range.begin + (source_num - @source_range.begin)
    else
      nil
    end
  end

  def reverse_lookup(dest_num)
    if @dest_range.include?(dest_num)
      @source_range.begin + (dest_num - @dest_range.begin)
    else
      nil
    end
  end
end

####

def process_chunk(almanac, chunk, category)
  chunk.split("\n")[1..].each do |range_line|
    range_parts = range_line.split
    almanac.add_range_mapping(category, range_parts[1].to_i, range_parts[0].to_i, range_parts[2].to_i)
  end
end

def process_file(filename, seeds_in_ranges=false)
  chunks = File.read(filename).split("\n\n")

  almanac = Almanac.new(chunks[0].split(": ")[1].split.map(&:to_i), seeds_in_ranges)

  process_chunk(almanac, chunks[1], "seed-soil")
  process_chunk(almanac, chunks[2], "soil-fertilizer")
  process_chunk(almanac, chunks[3], "fertilizer-water")
  process_chunk(almanac, chunks[4], "water-light")
  process_chunk(almanac, chunks[5], "light-temperature")
  process_chunk(almanac, chunks[6], "temperature-humidity")
  process_chunk(almanac, chunks[7], "humidity-location")

  almanac
end

####

test_almanac = process_file("day05-input-test.txt")
puts "Lowest location number (test): #{test_almanac.all_seeds.map{|seed| test_almanac.map_category_to_category("seed", seed, "location")}.min}"

real_almanac = process_file("day05-input.txt")
puts "Lowest location number (real): #{real_almanac.all_seeds.map{|seed| real_almanac.map_category_to_category("seed", seed, "location")}.min}"

test_almanac = process_file("day05-input-test.txt", true)
test_almanac.sort_range_mappings_per_category_by_dest
puts "Lowest location number part 2 (test): #{test_almanac.find_smallest_location_with_valid_seed}"

real_almanac = process_file("day05-input.txt", true)
real_almanac.sort_range_mappings_per_category_by_dest
puts "Lowest location number part 2 (real): #{real_almanac.find_smallest_location_with_valid_seed(50000000)}"
