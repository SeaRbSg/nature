class Vec
  attr_reader :contents

  def + other
    vec = self.contents.zip(other.contents).map { |s, o| s + o }
    self.class.new(*vec)
  end

  def - other
    vec = self.contents.zip(other.contents).map { |s, o| s - o }
    self.class.new(*vec)
  end

  def dot other
    self.contents.zip(other).map { |s, o| s*o }.reduce { |sum, elem| sum + elem }
  end

  def scale s
    vec = self.contents.map { |elem| elem*s }
    self.class.new(*vec)
  end

  def == other
    self.zip(other).all {|s, o| s == o}
  end

  def magnitude_squared
    self.contents.map {|elem| elem**2 }.reduce { |sum, elem| sum + elem }
  end

  def magnitude
    Math.sqrt(self.magnitude_squared)
  end

  def normalize
    m = self.magnitude
    if m == 0
      self.zero
    else
      vec = self.contents.map { |elem| elem.to_f/m }
      self.class.new(*vec)
    end
  end

  def distance_from other
    (other - self).magnitude
  end

  def distance_squared_from other
    (other - self).magnitude_squared
  end

  def clamp s
    m = self.magnitude
    if m == 0.0
      self.zero
    elsif m > s
      self.scale s.to_f/m
    else
      self
    end
  end

  def self.zero
    vec = Array.new(self.contents.length, 0)
    self.class.new vec
  end
end

class Vec2 < Vec
  attr_reader :x, :y
  def initialize x, y
    @contents = [x, y]
  end

  def x
    self.contents[0]
  end

  def y
    self.contents[1]
  end

  def self.random
    angle = rand * 2.0*Math::PI
    self.class.new Math.cos(angle), Math.sin(angle)
  end

  def self.random_positive
    self.zero.contents.map { |elem| rand }
  end

  def map &block
    Vec2.new block.call(x), block.call(y)
  end
end

class Vec3 < Vec
  attr_reader :x, :y, :z
  def initialize x, y, z
    @contents = [x, y, z]
  end

  def x
    self.contents[0]
  end

  def y
    self.contents[1]
  end

  def z
    self.contents[2]
  end

  def self.random
    angle = rand * 2.0*Math::PI
    self.class.new Math.cos(angle), Math.sin(angle)
  end

  def self.random_positive
    self.zero.contents.map { |elem| rand }
  end

  def map &block
    Vec2.new block.call(x), block.call(y)
  end
end


ORIGIN = Vec2.new 0.0, 0.0
