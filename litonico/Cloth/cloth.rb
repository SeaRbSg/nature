require 'graphics'
require './../vec'

WINSIZE = 500
PARTICLE_RADIUS = 5
EDGE_LEN = 50
GRAVITY = -1
WIDTH = 7
HEIGHT = 7

class Constraint
  attr_reader :a, :b
  def initialize a, b
    @a = a
    @b = b
  end

  def satisfy
    pa = a.position
    pb = b.position
    distance = pa.distance_from pb
    difference = EDGE_LEN - distance
    direction = (pb - pa).normalize
    force = direction.scale (difference/2.0)
    a.position -= force
    b.position += force
  end

  def draw window
    window.line self.a.position.x, self.a.position.y,
                self.b.position.x, self.b.position.y, :black
  end
end

class LeftPinConstraint
  attr_reader :a, :b
  def initialize a, b
    @a = a
    @b = b
  end

  def satisfy
    pa = a.position
    pb = b.position
    distance = pa.distance_from pb
    difference = EDGE_LEN - distance
    direction = (pb - pa).normalize
    force = direction.scale difference
    b.position += force
  end

  def draw window
    window.line self.a.position.x, self.a.position.y,
                self.b.position.x, self.b.position.y, :red
  end
end


class Particle
  attr_accessor :position, :prev_position, :acceleration

  def initialize pos=ORIGIN, acc=ORIGIN
    @position = pos
    @prev_position = pos
    @acceleration = acc
  end

  def move
    velocity = position - prev_position + acceleration
    self.prev_position = position
    self.position = position + velocity
    self.acceleration = Vec2.new 0, 0
  end

  def update
    apply_gravity
    move
  end

  def apply_gravity
    self.acceleration += Vec2.new(0, GRAVITY)
  end

  def draw window
    px = self.position.x
    py = self.position.y
    window.circle px, py, PARTICLE_RADIUS, :black, true
  end

  def distance_from other
    self.position.distance_from other.position
  end
end

class Pin < Particle
  def move
  end
end

class Cloth
  attr_reader :particles, :constraints

  def initialize
    @particles = []
    @constraints = []

    HEIGHT.times do |y|
      WIDTH.times do |x|
        p = Particle.new(ORIGIN + Vec2.new(x*50+50, 450-y*50))
        particles << p
      end
    end

    particles[0] = Pin.new particles[0].position
    particles[WIDTH-1] = Pin.new particles[WIDTH-1].position

    # Link particles horizontally
     HEIGHT.times do |y|
       particles[y*HEIGHT...y*HEIGHT+WIDTH].each_cons(2) do |p1, p2|
         constraints << Constraint.new(p1, p2)
       end
     end
    # Link particles vertically
    (HEIGHT-1).times do |y|
      WIDTH.times do |x|
        p1 = particles[y*HEIGHT+x]
        p2 = particles[(y+1)*HEIGHT+x]
        constraints << Constraint.new(p1, p2)
      end
    end

    # Constrain the top-left particle
    constraints[0] = LeftPinConstraint.new(particles[0], particles[1])
    constraints[(WIDTH-1)*HEIGHT] = LeftPinConstraint.new(particles[0], particles[WIDTH])

    # Constrain the top-right particle
    constraints[WIDTH-2] = LeftPinConstraint.new(particles[WIDTH-1], particles[WIDTH-2])
    constraints[(WIDTH-1)*HEIGHT+(WIDTH-1)] = LeftPinConstraint.new(particles[WIDTH-1], particles[WIDTH*2-1])
  end

  def update
    constraints.each do |c|
      c.satisfy
    end

    particles.each do |p|
      p.update
    end
  end
end

class ClothSimulation < Graphics::Simulation
  attr_reader :sim
  def initialize
    super WINSIZE, WINSIZE, 8, "Cloth"
    @sim = Cloth.new
  end

  def update dt
    sim.update
  end

  def draw dt
    clear :white

    sim.particles.each do |p|
      p.draw(self)
    end

    sim.constraints.each do |c|
      c.draw(self)
    end
  end
end

ClothSimulation.new.run
