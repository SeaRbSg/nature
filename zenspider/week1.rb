#!/usr/bin/ruby -w

$: << File.expand_path("~/Work/git/zenspider/graphics/lib")

require "graphics"

class Ball < Graphics::Body
  COUNT = 1000
  R = 2

  attr_accessor :stuck
  alias stuck? stuck

  def initialize w
    super

    self.a = random_angle / 2
    self.m = 1 + rand(10)
    self.stuck = false
  end

  def update
    return if stuck?
    move
    bounce
  end

  def touches? b
    (x-b.x).abs < 10 && (y-b.y).abs < 10
  end

  class View
    def self.draw w, b
      color = b.stuck? ? :white : :gray

      w.angle  b.x, b.y, b.a, 10+2*b.m, :red
      w.circle b.x, b.y, Ball::R, color, :filled
    end
  end
end

class DLASimulation < Graphics::Simulation
  attr_accessor :bs

  include ShowFPS

  def initialize
    super 640, 640, 16, "Bounce"

    self.bs = populate Ball
    register_bodies bs

    bs.first.stuck = true
  end

  def update n
    super

    handle_collisions
  end

  def handle_collisions
    bs.combination(2).each do |a, b|
      if (a.stuck? || b.stuck?) && a.touches?(b) then
        a.stuck = true
        b.stuck = true
      end
    end
  end
end

DLASimulation.new.run
