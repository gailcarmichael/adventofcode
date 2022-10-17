class BoxIDChecker

  def initialize(id_list)
    @id_list = id_list
  end

  def checksum
    hist_list = []
    @id_list.each do |id|
      hist_list << generate_histogram(id)
    end

    twice_thrice_count = generate_twice_thrice_count(hist_list)
   
    twice_thrice_count[:twice] * twice_thrice_count[:thrice]
  end

  def ids_one_char_differing
    @id_list.each_with_index do |id1, index|
      @id_list[index..-1].each do |id2|
        return [id1, id2] if characters_differing(id1, id2) == 1
      end
    end
  end

  private

  def generate_histogram(id)
    hist = Hash.new(0)
    id.each_char do |char|
      hist[char] += 1
    end
    hist
  end

  def generate_twice_thrice_count(hist_list)
    twice_thrice_count = Hash.new(0)
    hist_list.each do |hist|
      twice_thrice_count[:twice] += 1 if hist.values.include?(2)
      twice_thrice_count[:thrice] += 1 if hist.values.include?(3)
    end
    twice_thrice_count
  end

  def characters_differing(id1, id2)
    num_differing = 0
    id1.split('').each_with_index do |char1, index|
      num_differing += 1 if char1 != id2[index]
    end
    num_differing
  end

end

####

def get_id_list(filename)
  File.read(filename).strip.split("\n")
end

def run_part_one(id_list)
  checker = BoxIDChecker.new(id_list)
  checker.checksum
end

def run_part_two(id_list)
  checker = BoxIDChecker.new(id_list)
  checker.ids_one_char_differing
end

####

id_list_test = get_id_list("day02-input-test.txt")
id_list_real = get_id_list("day02-input.txt")

puts "Part 1 test: #{run_part_one(id_list_test)}"
puts "Part 1 real: #{run_part_one(id_list_real)}" 

puts "Part 2 test: #{run_part_two(id_list_test)}"
puts "Part 2 real: #{run_part_two(id_list_real)}"
