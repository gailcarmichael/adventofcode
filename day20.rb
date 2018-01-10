input = File.read("day20-input.txt").strip

class Triplet
  attr_accessor :x, :y, :z

  def initialize(x, y, z)
    @x = x
    @y = y
    @z = z
  end

  def to_s
    "(#{x}, #{y}, #{z})"
  end

  def ==(otherObj)
    result = @x == otherObj.x && @y == otherObj.y && @z == otherObj.z
  end

  def absoluteSize
    x.abs + y.abs + z.abs
  end

  def +(otherTriplet)
    @x += otherTriplet.x
    @y += otherTriplet.y
    @z += otherTriplet.z
    self
  end
end

class Particle
  attr_reader :pos, :vel, :acc, :index

  def initialize(pos, vel, acc, index)
    @pos = pos
    @vel = vel
    @acc = acc
    @index = index
  end

  def to_s
    "p=#{@pos}  v=#{@vel}  acc=#{@acc}   [index #{@index}]"
  end

  def manhattanDistFrom(otherPos)
    (@pos.x - otherPos.x).abs + 
      (@pos.y - otherPos.y).abs +
      (@pos.z - otherPos.z).abs
  end

  def tick
    @vel = @vel + @acc
    @pos = @pos + @vel
    self
  end

  def collidesWith(otherParticle)
    @pos == otherParticle.pos
  end
end


###
# Set up the data from the input

particles = Hash.new

input.split("\n").each_with_index do |line, index|
  match = /p=<(.+),(.+),(.+)>, v=<(.+),(.+),(.+)>, a=<(.+),(.+),(.+)>/.match(line)
  newParticle = Particle.new(Triplet.new(match[1].to_i,match[2].to_i,match[3].to_i),
                             Triplet.new(match[4].to_i,match[5].to_i,match[6].to_i),
                             Triplet.new(match[7].to_i,match[8].to_i,match[9].to_i),
                             index)
  particles[newParticle] = nil
end


###
# Find particle with the lowest acc (or vel and then pos on tie)

def findMinParticlesAccordingTo(valueName, particles)
  particles.each_key do |particle| 
    value = particle.public_send(valueName)
    particles[particle] = value.absoluteSize
  end
  minValues = particles.values.min
  minParticles = []
  particles.each {|particle,size| minParticles.push particle if minValues == size}
  minParticles
end

def findParticleClosestToZero(particles)
  minParticles = findMinParticlesAccordingTo('acc', particles)
  minParticles = findMinParticlesAccordingTo('vel', particles) if minParticles.length > 1
  minParticles = findMinParticlesAccordingTo('pos', particles) if minParticles.length > 1

  minParticles[0]
end

#p findParticleClosestToZero(particles)


###
# Go through some number of ticks, and remove particles that collide
particleList = particles.keys
100.times do
  p "tick"
  particleList.each {|particle| particle.tick}
  #p particleList
  collisions = []
  particleList.each do |particle|
    collisions += particleList.select {|otherP| (!otherP.equal? particle) && particle.collidesWith(otherP)}
  end
  particleList -= collisions
  p particleList.length
end


