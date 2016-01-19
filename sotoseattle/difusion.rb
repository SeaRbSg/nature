require 'graphics.rb'
require_relative './helpers/rainbows'

class Ball < Graphics::Body

  attr_accessor :polyp, :c, :r, :store

  COUNT = 1_000

  def initialize w
    super
    self.r = 2 + rand(7)
    self.m = 5 + rand(9)
    self.a = rand 360.0
    self.c = "cubehelix_#{160 + rand(200)}".to_sym
    self.polyp = w.polyp
    self.store = self
  end

  def update
    return if calcified?

    if self.store = polyp.touching(self)
      polyp.attach self
    else
      move
      bounce 0.0
    end
  end

  def calcify
    self.m = 0
  end

  def calcified?
    m == 0
  end

  def touches other
    distance_to_squared(other) <= (r + other.r) ** 2
  end

  class View
    def self.draw w, o
      if o.calcified?
        w.line o.x, o.y, o.store.x, o.store.y, o.c
        w.circle o.x, o.y, o.r/3, :gray
      else
        w.circle o.x, o.y, o.r, o.c, :fill
      end
    end
  end
end

class Polyp
  require 'kdtree'

  attr_accessor :kd, :cells

  def initialize cell
    self.cells = []
    attach cell
  end

  def attach cell
    cells << cell
    self.kd = Kdtree.new cell_data
    cell.calcify
  end

  def cell_data
    cells.map.with_index { |c, i| [c.x, c.y, i] }
  end

  def touching cell
    nearest = cells[kd.nearest cell.x, cell.y]
    return nearest if cell.touches nearest
    nil
  end
end

class Difuso < Graphics::Simulation

  attr_accessor :polyp, :spectrum

  def initialize
    super 800, 800

    self.spectrum = Graphics::Cubehelix.new
    self.initialize_rainbow spectrum, "cubehelix"

    seed = Ball.new self
    seed.x, seed.y = w/2, h/2

    self.polyp = Polyp.new seed

    balls = [seed]
    balls += populate Ball do |b|
      b.x, b.y = rand(w/4..w*3/4), rand(1..h/4)
    end

    register_bodies balls
  end
end

Difuso.new.run
