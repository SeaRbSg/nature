#!/usr/bin/env ruby -w

require "graphics"

class Particle < Graphics::Body
  COUNT = 2000

  def initialize w
    super

    self.a = rand 360
    self.m = 10
  end

  def center!
    self.x = w.w / 2
    self.y = w.h / 2
  end

  def update
    move
    wrap
  end

  def label
    l = "%.1f %.1f" % dx_dy
    w.text l, x-10, y-40, :white
  end

  def draw
    #w.angle x, y, a, 50, :red
    w.circle x, y, 5, :white, :filled
    # label
  end

  def wrap
    max_w, max_h = w.w, w.h

    if x < 0
      self.x = max_w
    elsif x > max_w
      self.x = 0
    end

    if y < 0
      self.y = max_h
    elsif y > max_h
      self.y = 0
    end
  end

  def distance_to_squared p
    dx = p.x - x
    dy = p.y - y
    dx * dx + dy * dy
  end
end

class DiffusionLimitedAggregationSimulation < Graphics::Simulation
  attr_accessor :particles, :structure

  def initialize
    super 800, 800, 16, "DLA"

    init
  end

  def init
    self.particles = populate Particle
    p = particles.pop
    p.center!
    self.structure = [p]
  end

  def update n
    particles.each(&:update)
    check_collisions
  end

  def check_collisions
    particles.delete_if do |p|
      structure.any? do |fp|
        if p.distance_to_squared(fp) < 110.0
          self.structure << p
          true
        else
          false
        end
      end
    end
  end

  def draw n
    clear
    particles.each(&:draw)
    structure.each(&:draw)
    #structure.first.label
    fps n
  end

  def handle_keys
    super
    init if SDL::Key.press? SDL::Key::SPACE
  end
end

DiffusionLimitedAggregationSimulation.new.run
