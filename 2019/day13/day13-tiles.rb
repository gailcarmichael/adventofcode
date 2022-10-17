class Game
    TILE_IDS = {0 => :empty, 1 => :wall, 2 => :block, 3 => :hor_paddle, 4 => :ball}

    attr_accessor :score

    def initialize
        @tile_grid = Hash.new(:empty)
        @min_x = @max_x = 0
        @min_y = @max_y = 0
    end

    def add_tile(x, y, tile_id)
        @tile_grid[[x,y]] = TILE_IDS[tile_id]

        case TILE_IDS[tile_id]
        when :ball
            @ball_coord = [x,y]
        when :hor_paddle
            @padde_coord = [x,y] 
        end
        
        @min_x = [@min_x, x].min
        @max_x = [@max_x, x].max
        
        @min_y = [@min_y, y].min
        @max_y = [@max_y, y].max
    end

    def to_s
        result = ""
        @min_y.upto(@max_y).each do |y|
            @min_x.upto(@max_x).each do |x|
                case @tile_grid[[x,y]]
                when :wall
                    result += "X"
                when :block
                    result += "-"
                when :hor_paddle
                    result += "="
                when :ball
                    result += "o"
                else
                    result += " "
                end
            end
            result += "\n"
        end
        result
    end

    def num_blocks
        @tile_grid.select{|coord,tile_id| tile_id==:block}.length
    end

    def joystick_pos
        return 0 if !@ball_coord

        if @ball_coord[0] < @padde_coord[0]
            -1
        elsif @ball_coord[0] > @padde_coord[0]
            1
        else
            0
        end
    end
end



