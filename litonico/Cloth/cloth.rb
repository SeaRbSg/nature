require 'graphics'
require './../vec'

WINSIZE = 500
PARTICLE_RADIUS = 5
EDGE_LEN = 50
GRAVITY = -0.1
WIDTH = 5
HEIGHT = 5

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
    a.acceleration -= force
    b.acceleration += force
  end

  def draw window
    window.line self.a.pos.x, self.a.pos.y, self.b.pos.x, self.b.pos.y, :black
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
    b.acceleration += force
  end

  def draw window
    window.line self.a.pos.x, self.a.pos.y, self.b.pos.x, self.b.pos.y, :red
  end
end


class Particle < Graphics::Body
  attr_accessor :velocity, :position, :acceleration
  alias pos position

  def initialize pos=ORIGIN, vel=ORIGIN, acc=ORIGIN
    @position = pos
    @velocity = vel
    @acceleration = acc
  end

  def move
    self.velocity = velocity + acceleration
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
    px = self.pos.x
    py = self.pos.y
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
        p = Particle.new(ORIGIN + Vec2.new(x*50+50, 400-y*50))
        particles << p
      end
    end

    particles[0] = Pin.new particles[0].pos

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
