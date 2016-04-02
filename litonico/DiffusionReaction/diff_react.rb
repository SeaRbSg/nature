require 'graphics'
require 'minitest/autorun'

WINSIZE = 80
W = 0.12 # Inhibition concentration

def distance_from v1, v2
  delta = [v2[0] - v1[0], v2[1] - v1[1]]
  return Math.sqrt(delta[0]**2 + delta[1]**2)
end

class Cell
  attr_accessor :type
  def initialize type
    self.type = type
  end

  def differentiated?
    type == :D
  end
end

class DiffusionReaction
  attr_reader :grid

  def initialize
    @grid = Array.new(WINSIZE){ Array.new(WINSIZE) { Cell.new :U } }
    grid[rand(WINSIZE)][rand(WINSIZE)] = Cell.new :D
    #neighbors(WINSIZE/2, WINSIZE/2, WINSIZE/10).each do |i, j|
    #  grid[i][j] = Cell.new :D
    #end
  end

  def draw window
    grid.each_with_index do |row, i|
      row.each_with_index do |cell, j|
        if cell.differentiated?
          window.screen[i, j] = window.color[:black]
        end
      end
    end
  end

  def neighbors i, j, radius
    ij = [i, j]
    top_left = [i - radius, j - radius]
    side = radius * 2
    ns = []
    (top_left[0]..top_left[0]+side).each do |ti|
      (top_left[1]..top_left[1]+side).each do |tj|
        ns << [ti, tj] if distance_from([ti, tj], ij) < radius
      end
    end
    ns
  end

  def differentiated_neighbors i, j, r
    neighbors(i, j, r).select do |ni, nj|
      begin
        grid[ni][nj].differentiated?
      rescue NoMethodError # Off the edge
      end
    end.count
  end

  def update
    grid.each_with_index do |row, i|
      row.each_with_index do |cell, j|
        id = differentiated_neighbors i, j, 6
        ad = differentiated_neighbors i, j, 3
        concentration = ad - W*id
        if concentration > 0
          grid[i][j].type =  :D
        elsif concentration < 0
          grid[i][j].type = :U
        end
      end
    end
  end
end

class SimulationTest < Minitest::Test
  def setup
    @sim = DiffusionReaction.new
  end

  def test_differentiated_neighbors
    differentiated = @sim.differentiated_neighbors(250, 250, 10)
    neighbors = @sim.neighbors(250, 250, 10)
    assert_equal(neighbors.length, differentiated)
  end
end

class DiffusionReactionSimulation < Graphics::Simulation
  attr_reader :sim

  def initialize
    super WINSIZE, WINSIZE, 8, "DLA"
    @sim = DiffusionReaction.new
    #self.screen = SDL::Screen.open 850, 850, 16, SDL::HWSURFACE
    clear :white
  end

  def update n
    sim.update
    puts "#{n}"
  end

  def draw_and_flip n
    super
  end

  def draw n
    sim.draw self
    #screen.update 0, 0, 0, 0
  end
end

# DiffusionReactionSimulation.new.run
