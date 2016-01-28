#!/usr/bin/ruby -w

$: << File.expand_path("~/Work/git/zenspider/graphics/lib")

require "graphics"

class Ball < Graphics::Body
  COUNT = 1000
  R = 2
  D = 1
  R2 = R*R + D

  attr_accessor :stuck
  alias stuck? stuck

  def initialize w
    super

    self.a = random_angle
    self.m = R2
    self.stuck = false
  end

  def update
    return if stuck?
    move
    bounce 0.0
  end

  def touches? b
    (x-b.x).abs < R2 && (y-b.y).abs < R2
  end

  class View
    def self.draw w, b
      color = b.stuck? ? :white : :gray

      w.angle  b.x, b.y, b.a, Ball::R2+b.m, :red unless b.stuck?
      w.circle b.x, b.y, Ball::R, color, :filled
    end
  end
end

class DLASimulation < Graphics::Simulation
  attr_accessor :bs

  WIDTH      = 800
  PART_SIDE  = 50
  PARTITIONS = PART_SIDE * PART_SIDE
  PART_WIDTH = WIDTH / PART_SIDE

  n = WIDTH / PART_SIDE.to_f
  if n.to_i != n then
    abort "WIDTH and PARTITIONS aren't compatible: %.2f" % n
  end

  GRID_WIDTH = PART_WIDTH
  include DrawGrid
  include ShowFPS

  attr_accessor :partitions

  def initialize
    super WIDTH, WIDTH, 16, "Coral"

    self.bs = populate Ball
    register_bodies bs

    bs.sample.stuck = true
    bs.sample.stuck = true
    bs.sample.stuck = true

    self.partitions = Array.new(PARTITIONS) do [] end
  end

  def update n
    super

    handle_collisions
  end

  def handle_collisions
    partition_into bs, partitions
    interesting = partitions.find_all { |p| p.any?(&:stuck?) && !p.none?(&:stuck?) }

    interesting.each do |subgroup|
      dead, alive = subgroup.partition(&:stuck?)

      next if dead.empty? or alive.empty?

      alive.each do |a|
        dead.each do |b|
          if a.touches? b then
            a.stuck = true
          end
        end
      end
    end
  end

  def scale b
    x = b.x.to_i
    y = b.y.to_i
    x = WIDTH-1 if x >= WIDTH
    y = WIDTH-1 if y >= WIDTH
    x = 0 if x < 0
    y = 0 if y < 0

    [x / PART_WIDTH, y / PART_WIDTH]
  end

  def partition b
    x, y = scale b
    x + PART_SIDE * y
  end

  def partition_into from, to, size=PARTITIONS, side=PART_WIDTH
    to.each(&:clear)

    from.each do |b|
      idx = partition b

      raise "BAD: #{b.x} x #{b.y} => #{idx}" if idx >= size

      to[idx]           << b
      to[idx+1]         << b if idx+1 < size
      to[idx-1]         << b if idx-1 >= 0
      to[idx-PART_SIDE] << b if idx-PART_SIDE >= 0
      to[idx+PART_SIDE] << b if idx+PART_SIDE < size
    end
  end
end

if ARGV.empty? then
  DLASimulation.new.run
else
  require "stackprof"
  StackProf.run(mode: :cpu, out: "#{Dir.pwd}/stackprof.dump") do
    DLASimulation.new.run
  end
end
