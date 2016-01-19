require 'graphics'
require './../vec'

WINSIZE = 500
PARTICLE_RADIUS = 5

class Particle < Graphics::Body
  attr_accessor :velocity, :position
  alias pos position

  def initialize pos=ORIGIN, vel=ORIGIN
    @position = pos
    @velocity = vel
  end

  def move
    self.position = position + velocity
  end

  ##
  # If particles hit one side of the window,
  # they come out the other side
  def wrap
    if position.x > WINSIZE
      self.position.x = position.x % WINSIZE
    elsif position.x < 0
      self.position.x = WINSIZE - position.x
    end

    if position.y > WINSIZE
      self.position.y = position.y % WINSIZE
    elsif position.y < 0
      self.position.y = WINSIZE - position.y
    end
  end

  def step
    move
    wrap
  end

  def draw window, color, filled
    px = self.pos.x
    py = self.pos.y
    window.circle px, py, PARTICLE_RADIUS, color, filled
  end

  def distance_from other
    self.position.distance_from other.position
  end
end

class DLA
  attr_reader :drifting, :stopped

  def initialize
    @drifting = []
    400.times do
      @drifting << drifting_particle
    end

    @stopped = [ Particle.new( Vec2.new(10, 10) ) ]
  end

  def drifting_particle_at_edges
    # Round each random position to start at a wall
    position = Vec2.random_positive.map(&:round) * WINSIZE
    velocity = Vec2.random * 5
    Particle.new(position, velocity)
  end

  def drifting_particle
    position = Vec2.random_positive * WINSIZE
    # Drifting from top-right to bottom-left
    velocity = Vec2.random + Vec2.new(-2,-2)
    Particle.new(position, velocity)
  end

  def hit_stopped? drifter
    stopped.any? do |p|
      drifter.distance_from(p) <= (PARTICLE_RADIUS*2)
    end
  end

  def finished
    drifting.count == 0
  end

  def update
    sleep if finished

    drifting.each do |drifter|
      if hit_stopped? drifter
        stopped << drifter
        drifting.delete drifter
      else
        drifter.step
      end
    end
  end
end

class DLASimulation < Graphics::Simulation
  attr_reader :sim
  def initialize
    super WINSIZE, WINSIZE, 8, "DLA"
    @sim = DLA.new
  end

  def update dt
    sim.update
  end

  def draw dt
    clear :white

    sim.stopped.each do |p|
      p.draw(self, :black, true)
    end

    sim.drifting.each do |p|
      p.draw(self, :black, false)
    end
  end
end

DLASimulation.new.run
