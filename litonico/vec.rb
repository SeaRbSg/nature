class Vec
  attr_reader :components

  def + other
    vec = self.components.zip(other.components).map { |s, o| s + o }
    self.class.new(*vec)
  end

  def - other
    vec = self.components.zip(other.components).map { |s, o| s - o }
    self.class.new(*vec)
  end

  def dot other
    self.components.zip(other).map { |s, o| s*o }.reduce(:+)
  end

  def scale s
    vec = self.components.map { |elem| elem*s }
    self.class.new(*vec)
  end

  def == other
    self.zip(other).all {|s, o| s == o}
  end

  def magnitude_squared
    self.components.map {|elem| elem**2 }.reduce(:+)
  end

  def magnitude
    Math.sqrt(self.magnitude_squared)
  end

  def normalize
    m = self.magnitude
    if m == 0
      self.zero
    else
      vec = self.components.map { |elem| elem.to_f/m }
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
    vec = Array.new(self.components.length, 0)
    self.class.new vec
  end
end

class Vec2 < Vec
  attr_reader :x, :y
  def initialize x, y
    @components = [x, y]
  end

  def x
    self.components[0]
  end

  def y
    self.components[1]
  end

  def self.random
    angle = rand * 2.0*Math::PI
    self.class.new Math.cos(angle), Math.sin(angle)
  end

  def self.random_positive
    self.zero.components.map { |elem| rand }
  end

  def map &block
    Vec2.new block.call(x), block.call(y)
  end
end

class Vec3 < Vec
  attr_reader :x, :y, :z
  def initialize x, y, z
    @components = [x, y, z]
  end

  def x
    self.components[0]
  end

  def y
    self.components[1]
  end

  def z
    self.components[2]
  end

  def self.random
    angle = rand * 2.0*Math::PI
    self.class.new Math.cos(angle), Math.sin(angle)
  end

  def self.random_positive
    self.zero.components.map { |elem| rand }
  end

  def map &block
    Vec2.new block.call(x), block.call(y), block.call(z)
  end
end


ORIGIN = Vec2.new 0.0, 0.0
V_ZERO = Vec2.new 0.0, 0.0
