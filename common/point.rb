# frozen_string_literal: true

# Class representing a point in 2 dimensions
class Point
  attr_accessor :x_value, :y_value

  def initialize(x_val, y_val)
    @x_value = x_val
    @y_value = y_val
  end

  UP =    Point.new(0, -1)
  DOWN =  Point.new(0, 1)
  LEFT =  Point.new(-1, 0)
  RIGHT = Point.new(1, 0)

  def +(other)
    Point.new(x_value + other.x_value, y_value + other.y_value)
  end

  def -(other)
    Point.new(x_value - other.x_value, y_value - other.y_value)
  end

  def *(other)
    Point.new(x_value * other.x_value, y_value * other.y_value)
  end

  def distance(other)
    (x_value - other.x_value).abs + (y_value - other.y_value).abs
  end

  def <=>(other_coordinate)
    distance(other_coordinate) <=> other_coordinate.distance(self)
  end

  def distance_vector(other)
    Point.new(x_value - other.x_value, y_value - other.y_value)
  end

  def eql?(other)
    return false unless other.is_a? Point

    x_value == other.x_value && y_value == other.y_value
  end

  def ==(other) = eql?(other)

  # @return [<Point>]
  def neighbours = [up, down, left, right]

  def corners = [right_up, left_up, right_down, left_down]

  def neighbourhood = neighbours + corners

  def up = self + UP
  def down = self + DOWN
  def left = self + LEFT
  def right = self + RIGHT

  def right_up   = self + UP + RIGHT
  def left_up    = self + UP + LEFT
  def right_down = self + DOWN + RIGHT
  def left_down  = self + DOWN + LEFT


  def hash = [x_value, y_value].hash

  def to_s = [x_value, y_value].to_s

  def to_a = [x_value, y_value]

  def combined_x_range(other)
    if x_value <= other.x_value
      (x_value..other.x_value)
    else
      (other.x_value..x_value)
    end
  end

  def combined_y_range(other)
    if y_value <= other.y_value
      (y_value..other.y_value)
    else
      (other.y_value..y_value)
    end
  end
end
