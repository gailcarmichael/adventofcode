class Rope
    DX = {"U" => 0, "D" => 0, "L" => -1, "R" => 1}
    DY = {"U" => -1, "D" => 1, "L" => 0, "R" => 0}

    attr_reader :head
    attr_reader :intermediate_knots

    def initialize(num_intermediate_knots=0)
        @start = [0,0]
        @head = [0,0]

        @intermediate_knots = Array.new
        (num_intermediate_knots+1).times {@intermediate_knots.push([0,0])} # tail at end
        
        @tail_visited = Hash.new(false)
        @tail_visited[@start] = true

        @min_x = @min_y = 0
        @max_x = @max_y = 0
    end

    def process_steps(step_list)
        step_list.each {|step| move_head(step[0], step[1])}
    end

    def num_spaces_tail_visited
        @tail_visited.values.filter{|value| value}.count
    end

    def to_s
        result = ""
        @min_y.upto(@max_y).each do |y|
            @min_x.upto(@max_x).each do |x|
                index = @intermediate_knots.find_index{|k| k == [x,y]}
                if @head == [x,y]
                    result += "H"
                elsif @intermediate_knots[-1] == [x, y]
                    result += "T"
                elsif index
                    result += "#{index+1}"
                elsif [x,y] == [0,0]
                    result += "S"
                else
                    result += "."
                end
            end
            result += "\n"
        end
        result
    end

    private

    def move_head(dir, amount)
        amount.times do
            @head[0] += DX[dir]
            @head[1] += DY[dir]

            follow = @head

            @intermediate_knots.each do |knot|
                catch_knot_up(knot, follow)
                follow = knot
            end

            @min_x = [@min_x, @head[0], @intermediate_knots.map{|k| k[0]}].flatten.min
            @min_y = [@min_y, @head[1], @intermediate_knots.map{|k| k[1]}].flatten.min

            @max_x = [@max_x, @head[0], @intermediate_knots.map{|k| k[0]}].flatten.max
            @max_y = [@max_y, @head[1], @intermediate_knots.map{|k| k[1]}].flatten.max

            @tail_visited[@intermediate_knots[-1]] = true
        end
    end

    def catch_knot_up(knot, follow)
        # same col
        if follow[0] == knot[0]
            if follow[1] - knot[1] > 1 
                knot[1] += DY["D"]
            elsif knot[1] - follow[1] > 1
                knot[1] += DY["U"]
            end
       
        # same row
        elsif follow[1] == knot[1]
            if follow[0] - knot[0] > 1
                knot[0] += DX["R"]
            elsif knot[0] - follow[0] > 1
                knot[0] += DX["L"]
            end
       
        # diagonal
        else
            if (knot[0]-follow[0]).abs > 1 || (knot[1]-follow[1]).abs > 1
                if follow[0] > knot[0]
                    knot[0] += DX["R"]
                else
                    knot[0] += DX["L"]
                end

                if follow[1] > knot[1]
                    knot[1] += DY["D"]
                else
                    knot[1] += DY["U"]
                end
            end
        end
    end
end

def process_file(filename)
    File.read(filename).strip.split("\n").map do |line|
       parts = line.split(" ")
       [parts[0], parts[1].to_i] 
    end
end

steps_test = process_file("day09-input-test.txt")
rope_test = Rope.new
rope_test.process_steps(steps_test)
puts "Num places tail visited (test): #{rope_test.num_spaces_tail_visited}"

steps_test_2 = process_file("day09-input-test2.txt")
rope_test_10 = Rope.new(8)
rope_test_10.process_steps(steps_test_2)
puts "Num places tail visited, 10 knots (test 2): #{rope_test_10.num_spaces_tail_visited}"

steps_real = process_file("day09-input.txt")
rope_real = Rope.new
rope_real.process_steps(steps_real)
puts "Num places tail visited (real): #{rope_real.num_spaces_tail_visited}"

rope_real_10 = Rope.new(8)
rope_real_10.process_steps(steps_real)
puts "Num places tail visited, 10 knots (real): #{rope_real_10.num_spaces_tail_visited}"