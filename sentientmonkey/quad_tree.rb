require "forwardable"

class QuadTree
  extend Forwardable
  attr_accessor :root
  def_delegators :root, :add, :find, :find_closest, :contains?

  def initialize w,h
    bbox = [0,w,0,h]
    @root = Node.new bbox
  end

  class Node
    MAX_POINTS = 4
    DIRECTIONS = [:NE, :NW, :SW, :SE]

    attr_accessor :quad, :points, :bbox
    def initialize bbox
      @quad = {}
      @points = []
      @bbox = bbox
    end

    def add point
      self.points << point
      if self.points.count > MAX_POINTS
        x0,x2,y0,y2 = bbox
        x1 = (x2-x0) / 2
        y1 = (y2-y0) / 2

        self.quad[:NW] = Node.new [x0,x1,y1,y2]
        self.quad[:NE] = Node.new [x1,x2,y1,y2]
        self.quad[:SW] = Node.new [x0,x1,y0,y1]
        self.quad[:SE] = Node.new [x1,x2,y0,y1]

        # add points to each
        self.points.each do |p|
          self.quad.each do |_,q|
            if q.contains? p
              q.add p
            end
          end
        end
        # clear existing points
        self.points = []
      end
    end

    def contains? point
      x,y = point
      x0,x1,y0,y1 = bbox

      if x0 <= x && x <= x1 &&
         y0 <= y && y <= y1
          true
        else
        false
      end
    end

    def find point
      if contains? point
        if !points.empty?
          points.find{|p| point == p }
        else
          self.quad.map{|_,q| q.find point }.find{|p| point == p }
        end
      end
    end

    def find_closest point, distance
      if contains? point
        if !points.empty?
          points.find{|p| point == p }
        else
          self.quad.map{|_,q| q.find_closest point, distance }.flatten
        end
      end
    end
  end
end
