# frozen_string_literal: true

require_relative '../generic'
require_relative '../common/matrix'
require_relative '../common/grid'
require 'set'

FILE_EXAMPLE = '2024/12/example'
FILE_EXAMPLE0 = '2024/12/example_small'
FILE = '2024/12/assignment'
USE_FILE = FILE_EXAMPLE0


class Garden
  attr_accessor :original_grid
  attr_accessor :garden_groups

  def initialize(grid)
    @original_grid = Grid.from_matrix(grid)
    @garden_groups = {}
    fill_garden_groups
  end

  def fill_garden_groups
    uniq_garden_values = @original_grid.uniq_values

    uniq_garden_values.each do |value|
      @garden_groups[value] = find_connecting_garden(value)
    end
  end

  def find_connecting_garden(value)
    all_coordinates = @original_grid.coordinates_for_value(value)
    queue = all_coordinates.clone
    groups = []
    while queue.any?
      coordinate = queue.shift
      coordinate_group = find_a_garden(coordinate, all_coordinates)
      coordinate_group.coordinates.each { |coord| queue.delete(coord) }
      groups << coordinate_group
    end
    groups
  end

  def find_a_garden(start_coordinate, all_coordinates)
    group = Set.new([start_coordinate])
    queue = start_coordinate.neighbours & all_coordinates
    while queue.any?
      neighbour_coord = queue.shift
      if group.include?(neighbour_coord)
        queue.delete(neighbour_coord)
      else
        group << neighbour_coord
        queue.append(*(neighbour_coord.neighbours & all_coordinates))
      end
    end
    GardenGroup.from_set(group)
  end

  def fencing_price
    @garden_groups.sum do |key, value|
      puts '------------------------'
      puts "For area called #{key} we have #{value.size} subplots"
      puts "with a perimeter of #{value.sum(&:region_price)}"
      value.sum(&:region_price)
    end
  end

  def new_fencing_price
    @garden_groups.sum do |key, values|
      values.sum do |value|
        nr_of_sides = value.sides
        value.discount_price
      end
    end
  end
end

# A class
class GardenGroup < Grid
  class << self
    def from_set(set)
      values_hash = {}
      set.each do |coordinate|
        walls_for_coord = []
        values_hash[coordinate] = walls_for_coord.append(*determine_walls(set, coordinate))
      end
      new(values_hash)
    end

    private

    def determine_walls(set, coordinate)
      walls = []
      walls << 'U' unless set.include?(coordinate.up)
      walls << 'D' unless set.include?(coordinate.down)
      walls << 'L' unless set.include?(coordinate.left)
      walls << 'R' unless set.include?(coordinate.right)
      walls
    end
  end

  def perimeter
    values.values.sum
  end

  def discount_price
    sides * area
  end

  def unfolded_values_to_coordinates
    collection = []
    @values_to_coordinates.each do |directions, coordinates|
      directions.each do |direction|
        coordinates.each do |coordinate|
          collection << [direction, coordinate]
        end
      end
    end
    !pp collection
    collection
  end

  def region_price
    area * perimeter
  end

  def area
    coordinates.size
  end

  def sides
    direction_to_coordinates =
      unfolded_values_to_coordinates.group_by(&:first)
                                    .transform_values { |values| values.map(&:last) }
    !pp direction_to_coordinates
    direction_to_coordinates.to_h do |direction, values|
      nr_of_groups = case direction
                     when 'U', 'D'
                       split_by_connecting_groups(values, :y_value, :x_value)
                     when 'L', 'R'
                       split_by_connecting_groups(values, :x_value, :y_value)
                     end
      [direction, nr_of_groups]
    end.values.sum
  end

  def split_by_connecting_groups(values, method, sort_method)
    sorted_by_direction = values.group_by(&method).values
    split_in_chunks = sorted_by_direction.map do |coord_block|
      sorted_block = coord_block.sort_by(&sort_method)
      sliced_sorted_block = sorted_block.slice_when do |i, j|
        (i.send(sort_method) - j.send(sort_method)).abs != 1
      end.to_a
      sliced_sorted_block.size
    end

    split_in_chunks.sum
  end
end

def data
  input = read_file(USE_FILE).map(&:chars)
  Garden.new(input)
end

puddle = data
puts data.new_fencing_price
