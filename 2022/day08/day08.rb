class TreeMap
    def initialize(grid_size)
        @grid_size = grid_size
        @tree_heights = Array.new(grid_size) { Array.new(grid_size, 0) }
    end

    def set_height(row, col, height)
        @tree_heights[row][col] = height
    end

    def tree_visible?(row, col)
        tree_height = @tree_heights[row][col]
        
        tree_visible_internal(row, col-1, tree_height, :left) ||
            tree_visible_internal(row, col+1, tree_height, :right) ||
            tree_visible_internal(row-1, col, tree_height, :up) ||
            tree_visible_internal(row+1, col, tree_height, :down)
    end

    def num_visible_trees
        num_visible = 0
        @tree_heights.each_with_index do |array, row|
            array.each_with_index do |height, col|
                num_visible += 1 if tree_visible?(row, col)
            end
        end
        num_visible
    end

    def tree_scenic_score(row, col)
        tree_height = @tree_heights[row][col]

        scenic_score_internal(row, col-1, tree_height, :left) *
            scenic_score_internal(row, col+1, tree_height, :right) *
            scenic_score_internal(row-1, col, tree_height, :up) *
            scenic_score_internal(row+1, col, tree_height, :down)
    end

    def highest_scenic_score
        scores = []
        @tree_heights.each_with_index do |array, row|
            array.each_with_index do |height, col|
                scores.push(tree_scenic_score(row, col))
            end
        end
        scores.max
    end

    private

    def tree_visible_internal(row, col, height_to_compare, direction)
        return true if row < 0 || col < 0 || row >= @grid_size || col >= @grid_size
        return false if @tree_heights[row][col] >= height_to_compare

        case direction
        when :left
            return tree_visible_internal(row, col-1, height_to_compare, :left)
        when :right
            return tree_visible_internal(row, col+1, height_to_compare, :right)
        when :up
            return tree_visible_internal(row-1, col, height_to_compare, :up)
        when :down
            return tree_visible_internal(row+1, col, height_to_compare, :down)
        end
    end

    def scenic_score_internal(row, col, height_to_compare, direction)
        return 0 if row < 0 || col < 0 || row >= @grid_size || col >= @grid_size
        return 1 if @tree_heights[row][col] >= height_to_compare

        case direction
        when :left
            return 1 + scenic_score_internal(row, col-1, height_to_compare, :left)
        when :right
            return 1 + scenic_score_internal(row, col+1, height_to_compare, :right)
        when :up
            return 1 + scenic_score_internal(row-1, col, height_to_compare, :up)
        when :down
            return 1 + scenic_score_internal(row+1, col, height_to_compare, :down)
        end
    end
end

def process_file(filename)
    lines = File.read(filename).strip.split("\n")
    map = TreeMap.new(lines.size)
    lines.each_with_index do |line, row|
        line.split("").each_with_index {|height, col| map.set_height(row, col, height.to_i)}
    end
    map
end

map_test = process_file("day08-input-test.txt")
puts "Num visible trees (test): #{map_test.num_visible_trees}"
puts "Highest scenic score (test): #{map_test.highest_scenic_score}"

map_real = process_file("day08-input.txt")
puts "Num visible trees (real): #{map_real.num_visible_trees}"
puts "Highest scenic score (real): #{map_real.highest_scenic_score}"