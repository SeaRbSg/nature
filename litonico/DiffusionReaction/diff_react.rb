require 'graphics'

WINSIZE = 500

def distance_from v1, v2
  delta = [v2[0] - v1[0], v2[1] - v1[1]]
  return Math.sqrt(delta[0]**2 + delta[1]**2)
end

class DiffusionReaction
  attr_reader :grid

  def initialize
    @grid = Array.new(WINSIZE){ Array.new(WINSIZE) { 0 } }
    grid[WINSIZE/2][WINSIZE/2] = 1
  end

  def draw window
    grid.each_with_index do |row, j|
      row.each_with_index do |cell, i|
        if cell == 1# TODO(lito): cell.differentiated?
          window.screen[i, j] = window.color[:black]
        end
      end
    end
  end

  def neighbors ij, radius
    i, j = ij
    top_left = [i - radius, j - radius]
    side = radius * 2
    ns = []
    (top_left[0]..top_left[0]+side).each do |ti|
      (top_left[1]..top_left[1]+side).each do |tj|
        # p distance_from([ti, tj], ij)
        ns << [ti, tj] if distance_from([ti, tj], ij) < radius
      end
    end
    p ns.length
    ns
  end

  def update
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

  def update dt
    sim.update
  end

  #def draw_and_flip dt
  #  self.draw n # No double-buffering
  #end

  def draw dt
    sim.draw self
    #screen.update 0, 0, 0, 0
  end
end

DiffusionReactionSimulation.new.run
