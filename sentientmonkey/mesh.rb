#!/usr/bin/env ruby -w

require "graphics"

class Particle < Graphics::Body
  COUNT = 100

  def initialize w, x, y
    super w
    self.x = x
    self.y = y
  end

  def update
    move
  end

  def label
    l = "%.1f %.1f" % dx_dy
    w.text l, x-10, y-40, :white
  end

  def draw
    w.circle x, y, 5, :white, :filled
  end
end


class MeshSimulation < Graphics::Simulation
  attr_accessor :particles

  def initialize
    super 800, 800, 16, "DLA"

    init
  end

  def init
    self.particles = []
    n = 100
    y = self.w / 2.0
    0.upto(800).each do |x|
      next if ((x % n) != 0)
      p = Particle.new self, x, y
      self.particles << p
    end
  end

  def update n
    particles.each(&:update)
  end

  def draw n
    clear
    particles.each(&:draw)
    fps n
  end

  def handle_keys
    super
    init if SDL::Key.press? SDL::Key::SPACE
  end
end

MeshSimulation.new.run
