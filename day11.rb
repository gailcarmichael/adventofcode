# Today's problem greatly helped by studying this guide:
# https://www.redblobgames.com/grids/hexagons/

input = File.read("day11-input.txt").strip


# dx, dy, dz for finding neighbours in cube coordinates
# for a hexagonal grid
dx = [1,  1,  0, -1, -1,  0]
dy = [-1, 0,  1,  1,  0, -1]
dz = [0, -1, -1,  0,  1,  1]

dirToIndex = {'n' => 2, 'ne' => 1, 'se' => 0,
              's' => 5, 'sw' => 4, 'nw' => 3}

####
# Walk through output, updating coordinates starting from
# origin (0,0), as well as saving the farthest distance

x = y = z = 0
maxDist = 0

input.split(",").each do |dir|
  x += dx[dirToIndex[dir]]
  y += dy[dirToIndex[dir]]
  z += dz[dirToIndex[dir]]

  dist = (x.abs+y.abs+z.abs)/2
  maxDist = dist if dist > maxDist
end

puts "(x,y,z)=(#{x}, #{y}, #{z})"
puts "Distance from origin is #{(x.abs+y.abs+z.abs)/2}"
puts "Max distance away is #{maxDist}"
