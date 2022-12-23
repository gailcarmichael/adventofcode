require 'set'

class Rock
    attr_reader :at_rest
    attr_reader :current_row
    attr_reader :current_col
    attr_reader :width
    attr_reader :height

    def initialize(init_row, init_col)
        @rockpattern = Hash.new(false) # key is [row,col], row increases upwards
        @current_row = init_row
        @current_col = init_col
        @width = @height = 0
        @at_rest = false
    end

    def to_s
        "#{self.class.name}: #{@current_row}, #{@current_col}"
    end

    def move_left(chamber)
        if !would_overlap_wall?(@current_row, @current_col-1, chamber) &&
            !would_hit_rocks?(@current_row, @current_col-1, chamber)
            @current_col -= 1
        end
    end

    def move_right(chamber)
        if !would_overlap_wall?(@current_row, @current_col+1, chamber) &&
            !would_hit_rocks?(@current_row, @current_col+1, chamber)
            @current_col += 1
        end
    end

    def fall_down_one(chamber)
        if @current_row == 0 || would_hit_rocks?(@current_row-1, @current_col, chamber)
            @at_rest = true
        else
            @current_row -= 1
        end
    end

    def update_chamber_filled_spaces(chamber)
        @rockpattern.filter{|loc, filled| filled}.keys.each do |loc|
            chamber.filled_spaces[[loc[0]+@current_row, loc[1]+@current_col]] = true
        end
    end

    private

    def would_hit_rocks?(new_row, new_col, chamber)
        chamber_relevant_rows = chamber.filled_spaces.filter do |chamber_loc, chamber_filled|
            chamber_loc[0] >= new_row - 1 && chamber_loc[0] <= new_row + @height + 1
        end

        @rockpattern.select{|location, filled| filled}.any? do |location, filled|
            rock_loc_in_chamber = [location[0]+new_row, location[1]+new_col]
            any_overlap = chamber_relevant_rows.any? do |chamber_row_loc, chamber_row_filled|
                chamber_row_loc[0] == rock_loc_in_chamber[0] && chamber_row_loc[1] == rock_loc_in_chamber[1]
            end
            any_overlap
        end
    end

    def would_overlap_wall?(new_row, new_col, chamber)
        new_col < 0 || (new_col+@width-1) >= chamber.width
    end
end

class HorzLineRock < Rock
    def initialize(init_row, init_col)
        super(init_row, init_col)

        @rockpattern[[0,0]] = true
        @rockpattern[[0,1]] = true
        @rockpattern[[0,2]] = true
        @rockpattern[[0,3]] = true

        @width = 4
        @height = 1
    end
end

class PlusRock < Rock
    def initialize(init_row, init_col)
        super(init_row, init_col)

        @rockpattern[[0,1]] = true
        
        @rockpattern[[1,0]] = true
        @rockpattern[[1,1]] = true
        @rockpattern[[1,2]] = true

        @rockpattern[[2,1]] = true

        @width = @height = 3
    end
end

class BackLRock < Rock
    def initialize(init_row, init_col)
        super(init_row, init_col)

        @rockpattern[[0,0]] = true
        @rockpattern[[0,1]] = true
        @rockpattern[[0,2]] = true

        @rockpattern[[1,2]] = true

        @rockpattern[[2,2]] = true

        @width = @height = 3
    end
end

class IRock < Rock
    def initialize(init_row, init_col)
        super(init_row, init_col)

        @rockpattern[[0,0]] = true
        @rockpattern[[1,0]] = true
        @rockpattern[[2,0]] = true
        @rockpattern[[3,0]] = true

        @width = 1
        @height = 4
    end
end

class SquareRock < Rock
    def initialize(init_row, init_col)
        super(init_row, init_col)

        @rockpattern[[0,0]] = true
        @rockpattern[[0,1]] = true

        @rockpattern[[1,0]] = true
        @rockpattern[[1,1]] = true

        @width = @height = 2
    end
end

class Chamber
    attr_reader :width

    @@BLOCK_ORDER = [:HorzLineRock, :PlusRock, :BackLRock, :IRock, :SquareRock]

    attr_reader :filled_spaces
    attr_reader :top_row_with_rocks

    def initialize(jet_dir_symbol_list)
        @jet_dirs = jet_dir_symbol_list
        @curr_jet_index = 0

        @filled_spaces = Hash.new(false)
        @top_row_with_rocks = -1
        @width = 7
    end

    def simulate_falling(num_rocks_to_fall, should_find_cycle=false)
        @rock_and_jet_index_history = Array.new
        @height_history = Hash.new

        # output = File.open( "temp-output.txt","w" )

        0.upto(num_rocks_to_fall-1) do |rock_num|
            next_rock = get_rock(rock_num)
            loop do
                push_rock_with_next_jet(next_rock)
                rock_falls_down(next_rock)
                break if next_rock.at_rest
            end
            update_for_just_rested_rock(next_rock)
            
            if should_find_cycle
                first_n_rows_string = ""
                (@top_row_with_rocks - 6).upto(@top_row_with_rocks) do |row|
                    0.upto(@width-1) do |col|
                        if @filled_spaces[[row,col]]
                            first_n_rows_string += "1"
                        else
                            first_n_rows_string += "0"
                        end
                    end
                end
                
                @rock_and_jet_index_history.push([rock_num % @@BLOCK_ORDER.size, @curr_jet_index, first_n_rows_string])
                @height_history[rock_num] = @top_row_with_rocks+1

                # output << "rock_num=#{rock_num} rock_index=#{rock_num % @@BLOCK_ORDER.size} jet_index=#{@curr_jet_index} height=#{@top_row_with_rocks+1} string=#{first_n_rows_string}\n"
            end
        end

        # output.close

        if should_find_cycle
            return if find_cycle 
        end

        @top_row_with_rocks+1
    end

    private

    def find_cycle
        5.upto(@rock_and_jet_index_history.size-5) do |start_index|
            offset_history = @rock_and_jet_index_history[start_index..-1]

            1.upto(2000/5).map{|i| i*5}.each do |chunk_size|
                history_chunks = Set.new
                offset_history.each_slice(chunk_size) do |chunk| 
                    history_chunks.add(chunk) if chunk.size == chunk_size
                end

                if history_chunks.count == 1
                    rock_num_start = start_index
                    rock_num_end = start_index + chunk_size - 1

                    puts "Cycle found!"
                    puts "offset=#{start_index} chunk_size=#{chunk_size}"
                    puts "Rock nums: start=#{rock_num_start} end=#{rock_num_end}"
                    puts "Heights: start=#{@height_history[rock_num_start]} end=#{@height_history[rock_num_end]}"
                    return true
                end
            end
        end
        return false
    end

    def update_for_just_rested_rock(rock)
        rock.update_chamber_filled_spaces(self)
        @top_row_with_rocks = [rock.current_row+rock.height-1,@top_row_with_rocks].max
    end

    def push_rock_with_next_jet(rock)
        case @jet_dirs[@curr_jet_index]
        when :<
            rock.move_left(self)
        when :>
            rock.move_right(self)
        end
        @curr_jet_index = (@curr_jet_index + 1) % @jet_dirs.size
    end

    def rock_falls_down(rock)
        rock.fall_down_one(self)
    end

    def get_rock(rock_num)
        Object
            .const_get(@@BLOCK_ORDER[rock_num % @@BLOCK_ORDER.size])
            .new(@top_row_with_rocks + 4, 2)
    end
end

################

def process_file(filename)
    Chamber.new(File.read(filename).split("").map(&:to_sym))
end


def calculate_total_height_using_cycles(chamber, start_rock, start_height, end_height, cycle_size)
    num_cycles = (1000000000000-start_rock)/cycle_size
    num_rocks_in_cycles = num_cycles*cycle_size

    # calculate height for however many cycles we can do
    height_for_cycles = (end_height-start_height+1)*num_cycles

    # calculate height without the cycles
    remaining_height = chamber.simulate_falling(1000000000000-num_rocks_in_cycles)

    height_for_cycles + remaining_height
end


# chamber_test = process_file("day17-input-test.txt")
# puts "Tower height after 2022 (test): #{chamber_test.simulate_falling(2022)}"

# chamber_test = process_file("day17-input-test.txt")
# chamber_test.simulate_falling(500, true)
# Cycle found!
# offset=80 chunk_size=35
# Rock nums: start=80 end=114
# Heights: start=126 end=178

# chamber_test = process_file("day17-input-test.txt")
# puts "Tower height after 1000000000000 (test): #{calculate_total_height_using_cycles(chamber_test, 80, 126, 178, 35)}"


# chamber_real = process_file("day17-input.txt")
# puts "Tower height after 2022 (real): #{chamber_real.simulate_falling(2022)}"

# chamber_real = process_file("day17-input.txt")
# chamber_real.simulate_falling(8000, true)
# Cycle found!
# offset=260 chunk_size=1730
# Rock nums: start=260 end=1989
# Heights: start=390 end=3036

chamber_real = process_file("day17-input.txt")
puts "Tower height after 1000000000000 (real): #{calculate_total_height_using_cycles(chamber_real, 260, 390, 3036, 1730)}"
