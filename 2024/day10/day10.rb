class TopoMap
  def initialize
    @grid = Hash.new
    @max_row = @max_col = 0

    @roots = Array.new
  end

  def add(row, col, height)
    @grid[[row,col]] = height

    @max_row = [@max_row, row].max
    @max_col= [@max_col, col].max

    @roots.push([row,col]) if height == 0
  end

  def to_s
    result = ""
    0.upto(@max_row) do |row|
      0.upto(@max_col) do |col|
        result += @grid[[row,col]].to_s
      end
      result += "\n"
    end
    result
  end

  def collect_children(row, col)
    children = Array.new
    children.push([row-1,col]) if (row-1).between?(0, @max_row)
    children.push([row+1,col]) if (row+1).between?(0, @max_row)
    children.push([row,col-1]) if (col-1).between?(0, @max_col)
    children.push([row,col+1]) if (col+1).between?(0, @max_col)
    children.select{|child| @grid[child] == @grid[[row,col]] + 1}
  end

  def trailhead_score(row, col,  allow_end_revisits=false, trail_ends_visited=Hash.new(false))
    children = collect_children(row,col)
    if children.empty?
      if @grid[[row,col]] == 9
        if allow_end_revisits || !(trail_ends_visited[[row,col]])
          trail_ends_visited[[row,col]] = true
          return 1
        end
      end
    else
      return children.map{|child| trailhead_score(child[0], child[1], allow_end_revisits, trail_ends_visited)}.sum
    end
    0
  end

  def sum_of_trailhead_scores(allow_end_revisits=false)
    @roots.map{|root| trailhead_score(root[0], root[1], allow_end_revisits)}.sum
  end
end

#########################

def process_file(filename)
  topomap = TopoMap.new
  File.read(filename).strip.split("\n").each_with_index do |line, row|
    line.split("").each_with_index do |char, col|
      topomap.add(row,col,char.to_i)
    end
  end
  topomap
end

puts
topomap = process_file("day10-input-test.txt")
puts "Sum of scores of trailheads (test): #{topomap.sum_of_trailhead_scores}"
puts "Sum of ratings of trailheads (test): #{topomap.sum_of_trailhead_scores(true)}"

puts
topomap = process_file("day10-input.txt")
puts "Sum of scores of trailheads (real): #{topomap.sum_of_trailhead_scores}"
puts "Sum of ratings of trailheads (real): #{topomap.sum_of_trailhead_scores(true)}"
