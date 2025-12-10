# frozen_string_literal: true

require_relative 'coordinate'

# Class representing a grid consisting of coordinates
class Grid
  attr_accessor :coordinates, :values, :values_to_coordinates
  attr_reader :x_size, :y_size

  class << self
    def from_matrix(matrix)
      new_grid = {}
      matrix.each_with_index do |row, row_index|
        row.each_with_index do |cell, column_index|
          new_grid[Point.new(column_index, row_index)] = cell
        end
      end
      new(new_grid)
    end
  end

  def initialize(values)
    @values = values
    update_attributes
  end

  # @return [<Point>]
  def neighbours(coord) = in_grid(coord.neighbours)

  def neighbourhood(coord) = in_grid(coord.neighbourhood)

  def distance(start_point, end_point) = start_point.distance(end_point)

  # @return [<Point>]
  def in_grid(coordinates)
    coordinates.select {|coord| coord.x_value < x_size && coord.y_value < y_size}
  end

  def coordinates_for_value(value) = @values_to_coordinates[value] || []

  def print_grid
    (0...y_size).each do |y|
      puts (0...x_size).map { |x| value(x, y) }.join('')
    end
  end

  def to_s = values.to_s

  def [](coord) = values[coord]

  def value(x, y) = values[Point.new(x, y)]

  def update(coord, value)
    old_value = values[coord]
    values[coord] = value
    @values_to_coordinates[old_value].delete(coord)
    @values_to_coordinates[value] ||= []
    @values_to_coordinates[value] << coord
  end

  def uniq_values = values.values.uniq

  def coordinate_in_grid?(coordinate) = values.key?(coordinate)

  def clone = self.class.new(values.to_a.to_h)

  def height = y_size

  def width = x_size

  def update_values_to_coordinates!
    @values_to_coordinates =
      @values.group_by { |_key, value| value }.transform_values { |val| val.map(&:first) }
  end

  private

  def update_attributes
    @coordinates = values.keys
    @x_size = coordinates.map(&:x_value).uniq.length
    @y_size = coordinates.map(&:y_value).uniq.length
    @values_to_coordinates =
      @values.group_by { |_key, value| value }.transform_values { |val| val.map(&:first) }
  end
end
