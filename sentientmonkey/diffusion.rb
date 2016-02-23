#!/usr/bin/env ruby -w

require "graphics"
require "graphics/rainbows"

class Particle < Graphics::Body
  RU = 0.082
  RV = 0.041
  attr_accessor :concentration, :size

  def initialize w,x,y,size
    super w
    self.x = x
    self.y = y
    self.size = size
    self.concentration = rand
  end

  def draw spectrum
    color = spectrum.clamp(concentration*30 + 60, 0, 360).to_i
    w.rect x, y, size, size, "cubehelix_#{color}".to_sym, true
  end
end

class DiffusionSimulation < Graphics::Simulation
  attr_accessor :particles, :spectrum

  def initialize
    super 600, 600, 16, "Diffusion"

    self.spectrum = Graphics::Cubehelix.new
    self.initialize_rainbow spectrum, "cubehelix"

    self.particles = []

    n = 10
    self.particles = 0.step(self.w, n).map do |x|
      0.step(self.h, n).map do |y|
        Particle.new self, x, y, n
      end
    end
  end

  def update n
    #TODO
  end

  def draw n
    clear
    particles.each do |row|
      row.each do |particle|
        particle.draw spectrum
      end
    end
    fps n
  end

  def handle_keys
    super
    init if SDL::Key.press? SDL::Key::SPACE
  end
end

DiffusionSimulation.new.run
