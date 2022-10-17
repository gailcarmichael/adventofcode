class CartTracks

  NEXT_CORNER_DIR = {up:    {'/' => :right, "\\" => :left},
                     right: {'/' => :left, "\\" => :right},
                     left:  {'/' => :left,  "\\" => :right},
                     down:  {'/' => :right, "\\" => :left}}

  def initialize(w=5, h=12)
    @tracks = Hash.new
    @carts = Array.new
    @width = w
    @height = h
  end

  def add_item(x, y, character)
    if ['>','<'].include?(character)
      add_cart(x, y, character)
      add_track(x, y, '-')
    elsif ['^','v'].include?(character)
      add_cart(x, y, character)
      add_track(x, y, '|')
    elsif ['|','-','/','\\','+'].include?(character)
      add_track(x, y, character)
    else
      raise "Invalid character: #{character}"
    end
  end

  def tick
    sort_carts

    to_delete = []

    @carts.each do |cart|
      next if cart.crashed

      cart.move

      track = @tracks[[cart.x, cart.y]]
      if track == '+'
        cart.turn_intersection
      elsif (track == '/') or (track == "\\")
        cart.turn(NEXT_CORNER_DIR[cart.current_direction][track])
      end

      #puts cart

      collided_carts = find_collisions(cart)
      if !collided_carts.empty?
        puts "Collision at [#{cart.x},#{cart.y}]"
        cart.crashed = true
        collided_carts.each {|cart| cart.crashed = true}
      end
    end

    @carts.reject! {|cart| cart.crashed}

    if (@carts.length == 1)
      return [@carts.last.x, @carts.last.y]
    else
      return nil
    end
  end

  def to_s
    result = ""
    0.upto(@width) do |y|
      0.upto(@height) do |x|
        cart = @carts.select {|cart| cart.x == x && cart.y == y}.first
        if cart
          result += direction_to_character(cart.current_direction)
        elsif @tracks[[x,y]]
          result += @tracks[[x,y]]
        else
          result += " "
        end
      end
      result += "\n"
    end
    result
  end

  private

  def add_track(x, y, character)
    @tracks[[x,y]] = character
  end

  def add_cart(x, y, character)
    direction = character_to_direction(character)
    @carts << Cart.new(x, y, direction)
  end

  def sort_carts
    @carts.sort! do |cart1, cart2|
      if cart1.y < cart2.y
        -1
      elsif cart1.y == cart2.y
        cart1.x <=> cart2.x
      else
        1
      end 
    end
  end

  def find_collisions(cart1)
    @carts.select {|cart2| cart1 != cart2 && cart1.crash?(cart2)}
  end

  def character_to_direction(character)
    case character
      when '>'
        :right
      when '<'
        :left
      when '^'
        :up
      when 'v'
        :down
      end
  end

  def direction_to_character(direction)
    case direction
    when :right
      '>'
    when :left
      '<'
    when :up
      '^'
    when :down
      'v'
    end
  end
end

class Cart
  DX_FOR_DIRECTION = {up: 0,  left: -1, down: 0, right: 1}
  DY_FOR_DIRECTION = {up: -1, left: 0,  down: 1, right: 0}

  TURN_LEFT_NEW_DIR =  {up: :left,  left: :down, down: :right, right: :up}
  TURN_RIGHT_NEW_DIR = {up: :right, left: :up,   down: :left,  right: :down}

  NEXT_INTERSECTION_DIR = [:left, :straight, :right]

  attr_reader :x, :y, :current_direction
  attr_accessor :crashed

  def initialize(init_x, init_y, current_direction)
    @x = init_x
    @y = init_y
    @current_direction = current_direction
    @last_direction_turned = -1
    @crashed = false
  end

  def to_s
    "[#{x}, #{y}, #{current_direction}, #{crashed}]"
  end

  def turn_intersection
    @last_direction_turned = (@last_direction_turned + 1) % NEXT_INTERSECTION_DIR.length
    turn(NEXT_INTERSECTION_DIR[@last_direction_turned])
  end

  def turn(direction)
    @current_direction = 
      case direction
      when :left
        TURN_LEFT_NEW_DIR[@current_direction]
      when :right
        TURN_RIGHT_NEW_DIR[@current_direction]
      else
        @current_direction
      end
  end

  def move
    @x += DX_FOR_DIRECTION[@current_direction]
    @y += DY_FOR_DIRECTION[@current_direction]
  end

  def crash?(other_cart)
    (x == other_cart.x) && (y == other_cart.y)
  end
end

###

def process_file(filename, args=nil)
  cart_tracks = nil
  if (args)
    cart_tracks = CartTracks.new(args[0], args[1])
  else
    cart_tracks = CartTracks.new
  end

  File.read(filename).split("\n").each_with_index do |line, y|
    line.split('').each_with_index do |character, x|
      if character.strip != ''
        cart_tracks.add_item(x, y, character)
      end
    end
  end

  loop do
    # puts '---'
    # puts cart_tracks.to_s

    cart_coord = cart_tracks.tick
    if cart_coord
      puts "Last cart coord: #{cart_coord}"
      break
    end

    # sleep 1
    # gets
  end
end

#process_file("day13-input-test.txt", [8,8])
process_file("day13-input.txt", [150, 150])
