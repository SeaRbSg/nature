require 'graphics'
require './../vec'

WINSIZE = 500
G = 0.6

class Euler
  # Fun to start with, but full of errors if acceleration is not constant!
  attr_accessor :velocity

  def initialize
    @velocity = V_ZERO
  end

  def next_position position, acceleration
    self.velocity = velocity + acceleration
    position = position + velocity
    position
  end
end

class Verlet
  # Much less error, but total energy decays over time
  attr_accessor :prev_position

  def initialize prev_position
    @prev_position = prev_position
  end

  def next_position position, acceleration
    velocity = position - prev_position + acceleration
    self.prev_position = position
    position = position + velocity
    position
  end
end

class Planet
  attr_accessor :position, :acceleration, :mass, :integrator

  def initialize pos=ORIGIN, acc=V_ZERO, mass=10
    @position = pos
    @acceleration = acc
    @mass = mass

    @integrator = Verlet.new position
  end

  def move
    self.position = integrator.next_position position, acceleration
    self.acceleration = V_ZERO
  end

  def update
    move
  end

  def draw window
    px = position.x
    py = position.y

    window.circle px, py, mass, :black, true
  end

  def distance_squared_from other
    position.distance_squared_from other.position
  end
end

class Orbits
  attr_reader :planets

  def initialize
    @planets = []
    planets << Planet.new(Vec2.new(100, 100), Vec2.new(2, -2), 5)
    planets << Planet.new(Vec2.new(100, 250), Vec2.new(1, -0.5), 20)
    planets << Planet.new(Vec2.new(400, 400), Vec2.new(-2, 2), 10)
  end

  def gravitate
    planets.combination(2).each do |planet1, planet2|
      apply_gravity(planet1, planet2)
    end
  end

  def update
    gravitate
    planets.each(&:update)
  end

  def draw window
    planets.each do |planet|
      planet.draw(window)
    end
  end

  def apply_gravity planet1, planet2
    force = gravitation_force planet1, planet2
    direction = planet2.position - planet1.position

    # Bigger things move slower
    # (aka acceleration = force / mass)
    accel1 = force * (1.0/planet1.mass)
    accel2 = force * (1.0/planet2.mass)

    planet1.acceleration += direction.scale accel1
    planet2.acceleration -= direction.scale accel2
  end

  def gravitation_force planet1, planet2
    distance_squared = planet2.distance_squared_from(planet1)
    G * (planet1.mass * planet2.mass / distance_squared.to_f)
  end
end

class OrbitWindow < Graphics::Simulation
  attr_reader :simulation
  def initialize
    super WINSIZE, WINSIZE, 8, "Orbits"
    @simulation = Orbits.new
  end

  def update dt
    simulation.update
  end

  def draw dt
    clear :white
    simulation.draw self
  end
end

OrbitWindow.new.run
