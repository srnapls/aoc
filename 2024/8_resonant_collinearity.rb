# frozen_string_literal: true

require_relative '../generic'
require_relative '../common/grid'
require_relative '../common/point'
require 'set'

FILE_EXAMPLE = '2024/8/example'
FILE_EXAMPLE0 = '2024/8/example0'
FILE = '2024/8/assignment'
USE_FILE = FILE

# A class representing the Guard
class AntinodeGrid
  attr_accessor :map, :x_size, :y_size

  def initialize(mapping)
    @map = {}

    mapping.each_with_index do |row, row_index|
      row.each_with_index do |value, column_index|
        coord = Point.new(column_index, row_index)
        if value != '.'
          @map[value] ||= Set.new
          @map[value] << coord
        end
      end
    end
    @map['#'] = Set.new
    @x_size = mapping.first.length
    @y_size = mapping.length
  end

  def add_antinodes_pt1
    @map.reject { |k, _v| k == '#' }.each_value do |coordinates|
      add_antinode_pt1(coordinates)
    end
  end

  def add_antinode_pt1(coordinates)
    coordinates.to_a.combination(2).each do |perm|
      coord1, coord2 = perm
      [coord1.distance_vector(coord2) + coord1,
       coord2.distance_vector(coord1) + coord2].each do |coordinate|
        @map['#'] << coordinate if valid_coordinate?(coordinate)
      end
    end
  end

  def add_antinodes_pt2
    @map.reject { |k, _v| k == '#' }.each_value do |coordinates|
      add_antinode_pt2(coordinates)
    end
  end

  def add_antinode_pt2(coordinates)
    coordinates.to_a.combination(2).each do |perm|
      coord1, coord2 = perm
      two_to_one_d_vector = coord1.distance_vector(coord2)
      one_to_two_d_vector = coord2.distance_vector(coord1)
      coordinate = coord2
      while valid_coordinate?(coordinate)
        @map['#'] << coordinate
        coordinate += two_to_one_d_vector
      end
      coordinate = coord1
      while valid_coordinate?(coordinate)
        @map['#'] << coordinate
        coordinate += one_to_two_d_vector
      end
    end
  end

  def valid_coordinate?(coordinate)
    coordinate.x_value >= 0 && coordinate.y_value >= 0 &&
      coordinate.x_value < x_size && coordinate.y_value < y_size
  end
end

def data
  input = read_file(USE_FILE)
  AntinodeGrid.new(input.map { |row| row.split('') })
end

grid = data
grid.add_antinodes_pt2
puts grid.map['#'].count


