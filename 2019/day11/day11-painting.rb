class Robot
    TURN_LEFT = {UP: :LEFT, LEFT: :DOWN, DOWN: :RIGHT, RIGHT: :UP}
    TURN_RIGHT = {UP: :RIGHT, RIGHT: :DOWN, DOWN: :LEFT, LEFT: :UP}

    MOVE_DX = {UP: 0, DOWN: 0, LEFT: -1, RIGHT: 1}
    MOVE_DY = {UP: -1, DOWN: 1, LEFT: 0, RIGHT: 0}

    attr_reader :curr_dir

    def initialize
        @curr_x = @curr_y = 0
        @curr_dir = :UP
    end

    def turn_left
        @curr_dir = TURN_LEFT[@curr_dir]
    end

    def turn_right
        @curr_dir = TURN_RIGHT[@curr_dir]
    end

    def move
        @curr_x += MOVE_DX[@curr_dir]
        @curr_y += MOVE_DY[@curr_dir]
    end

    def coord
        [@curr_x, @curr_y]
    end
end

class PaintableArea
    def initialize
        @panel_colours = Hash.new(0)
        @panel_colours[[0,0]] = 1

        @robot = Robot.new
        @min_x = @max_x = 0
        @min_y = @max_y = 0
    end

    def to_s
        result = ""

        (@min_y..@max_y).each do |y|
            (@min_x..@max_x).each do |x|
                if @robot.coord == [x,y]
                    result += case @robot.curr_dir
                    when :UP
                        "^"
                    when :RIGHT
                        ">"
                    when :DOWN
                        "v"
                    when :LEFT
                        "<"
                    end
                else
                    result += @panel_colours[[x,y]] == 0 ? "." : "\#"
                end
            end
            result += "\n"
        end

        result
    end

    def robot_panel_color
        @panel_colours[@robot.coord]
    end

    def paint_robot_panel(colour)
        return unless (colour == 0 || colour == 1)
        coord = @robot.coord
        
        @panel_colours[coord] = colour

        @min_x = [@min_x, coord[0]].min
        @min_y = [@min_y, coord[1]].min

        @max_x = [@max_x, coord[0]].max
        @max_y = [@max_y, coord[1]].max
    end

    def turn_and_move_robot(direction)
        if direction == 0
            @robot.turn_left
        else
            @robot.turn_right
        end
        @robot.move
    end

    def num_painted_panels
        @panel_colours.keys.length
    end
end



# ship_to_paint = PaintableArea.new
# [1,0, 0,0, 1,0, 1,0, 0,1, 1,0, 1,0].each_with_index do |instruction, index|
#     if index % 2 == 0
#         ship_to_paint.paint_robot_panel(instruction)
#     else
#         ship_to_paint.turn_and_move_robot(instruction)
#     end
# end
# puts ship_to_paint
# puts "painted #{ship_to_paint.num_painted_panels} panels"





