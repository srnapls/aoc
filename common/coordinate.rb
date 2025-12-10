# frozen_string_literal: true

# Class representing a point in 2 dimensions
class Coordinate
  include Enumerable

  attr_accessor :values

  def initialize(values)
    @values = values
  end

  def +(other)
    raise 'Not same dimensions' if size != other.size

    new_coords = self.map.zip(other.to_a) do |value, other_value|
      value + other_value
    end
    Coordinate.new(new_coords)
  end

  def -(other)
    raise 'Not same dimensions' if size != other.size

    new_coords = self.map.zip(other.to_a) do |value, other_value|
      value - other_value
    end
    Coordinate.new(new_coords)
  end

  def *(other)
    raise 'Not same dimensions' if size != other.size

    new_coords = self.map.zip(other.to_a) do |value, other_value|
      value * other_value
    end
    Coordinate.new(new_coords)
  end

  def size
    @values.length
  end

  def distance(other)
    self.map.zip(other.to_a) do |value, other_value|
      (value - other_value).abs
    end.sum
  end

  def euclidean_distance(other)
    squared_diffs = self.to_a.zip(other.to_a).map do |value, other_value|
      (value - other_value) ** 2
    end
    # Math.sqrt(squared_diffs.sum)
    squared_diffs.sum
  end

  def <=>(other_coordinate)
    distance(other_coordinate) <=> other_coordinate.distance(self)
  end

  def to_a
    @values
  end

  def each
    @values.each {|item| yield item}
  end

  def inspect
    @values.inspect
  end
end
