# frozen_string_literal: true

require_relative '../generic'
require_relative '../common/point'
require_relative '../common/grid'
require 'set'

FILE_EXAMPLE_L = '2024/15/example'
FILE_EXAMPLE_S = '2024/15/example_small'
FILE_EXAMPLE_XS = '2024/15/example_smaller'
FILE = '2024/15/assignment'
USE_FILE = FILE

# Added methods for coordinates in the warehouse
class WarehousePoint < Point
  def gps_coordinate
    100 * y_value + x_value
  end
end

# A class representing the warehouse
class Warehouse < Grid
  BOX = 'O'
  WALL = '#'

  def gps_coordinates_sum
    update_values_to_coordinates!
    @values_to_coordinates[BOX].map(&:gps_coordinate).sum
  end

  def blocks_movable?(coordinate, direction)
    end_coordinate = end_of_block_of_blocks(coordinate, direction)
    values[end_coordinate].nil?
  end

  def box?(value)
    value == BOX
  end

  def end_of_block_of_blocks(coordinate, direction)
    coordinate += direction
    coordinate += direction while box?(values[coordinate])
    coordinate
  end

  def move_blocks!(coordinate, direction)
    end_coord = end_of_block_of_blocks(coordinate, direction)
    values[end_coord] = 'O'
  end

  def print_grid
    (0...y_size).each do |y|
      puts (0...x_size).map { |x| value(x, y) || '.' }.join('')
    end
  end
end

class Robot
  attr_reader :route
  attr_accessor :position, :grid

  SIGNAL = '@'

  def initialize(grid, route)
    @grid = grid
    @position = grid.values_to_coordinates[SIGNAL].first
    @route = route
  end

  def question_1
    move_route
    grid.gps_coordinates_sum
  end
  alias question_2 question_1

  def move_route
    route.each do |direction|
      step(direction)
    end
  end

  def step(direction)
    new_position = position + direction
    case grid.value(*new_position)
    when nil
      move!(new_position)
    when grid.class::WALL
      # do nothing
    when grid.class::BOX, grid.class::BOX_L, grid.class::BOX_R
      if grid.blocks_movable?(new_position, direction)
        grid.move_blocks!(new_position, direction)

        move!(new_position)
      end
    end
  end

  def move!(new_position)
    grid.update(new_position, SIGNAL)
    grid.update(position, nil)
    @position = new_position
  end
end

class ChunkyWarehouse < Warehouse
  BOX_L = '['
  BOX_R = ']'

  def gps_coordinates_sum
    update_values_to_coordinates!
    @values_to_coordinates[BOX_L].map(&:gps_coordinate).sum
  end

  def box?(value)
    [BOX_L, BOX_R].include? value
  end

  alias orig_blocks_movable? blocks_movable?

  def blocks_movable?(coordinate, direction)
    if [Point::LEFT, Point::RIGHT].include?(direction)
      orig_blocks_movable?(coordinate, direction)
    else
      blocks_that_move = moving_blocks(coordinate, direction)
      blocks_that_move.all? do |block_coordinate|
        values[block_coordinate + direction] != WALL
      end
    end
  end

  alias orig_move_blocks! move_blocks!
  def move_blocks!(coordinate, direction)
    if [Point::LEFT, Point::RIGHT].include?(direction)
      move_blocks_horizontal!(coordinate, direction)
    else
      move_blocks_vertical!(coordinate, direction)
    end
  end

  def move_blocks_horizontal!(coordinate, direction)
    end_coord = end_of_block_of_blocks(coordinate, direction)
    while coordinate != end_coord
      coordinate += direction
      if values[coordinate] == BOX_L
        update(coordinate, BOX_R)
      elsif values[coordinate] == BOX_R
        update(coordinate, BOX_L)
      elsif direction == Point::LEFT # when nothing was there
        update(coordinate, BOX_L)
      else
        update(coordinate, BOX_R)
      end
    end
  end

  def move_blocks_vertical!(coordinate, direction)
    blocks = moving_blocks(coordinate, direction)
    sorted_blocks = if direction == Point::UP
                      blocks.sort_by(&:y_value)
                    else
                      blocks.sort_by(&:y_value).reverse
                    end

    sorted_blocks.slice_when { |c1, c2| c1.y_value != c2.y_value }
                 .each do |layer|
      layer.each do |box_coord|
        update(box_coord + direction, values[box_coord])
        update(box_coord, nil)
      end
    end
  end

  def moving_blocks(coordinate, direction)
    if [Point::LEFT, Point::RIGHT].include?(direction)
      moving_blocks_horizontal(coordinate, direction)
    else
      moving_blocks_vertical(coordinate, direction)
    end
  end

  def moving_blocks_horizontal(coordinate, direction)
    blocks = []
    while [BOX_L, BOX_R].include?(values[coordinate])
      blocks << coordinate
      coordinate += direction
    end
    blocks
  end

  def moving_blocks_vertical(coordinate, direction)
    blocks = Set.new
    blocks_to_check = [coordinate]
    until blocks_to_check.empty?
      block_coord = blocks_to_check.shift
      blocks_to_check.delete(block_coord)
      next if blocks.include?(block_coord) || values[block_coord].nil? || values[block_coord] == WALL

      blocks << block_coord
      if values[block_coord] == BOX_R
        blocks_to_check << block_coord.left
      elsif values[block_coord] == BOX_L
        blocks_to_check << block_coord.right
      end

      blocks_to_check << block_coord + direction
    end
    blocks
  end
end

def widen(char)
  case char
  when '.'
    [nil, nil]
  when 'O'
    ['[', ']']
  when '#'
    ['#', '#']
  when '@'
    ['@', nil]
  end
end

# wide is used for part 2
def data(wide: false)
  @data ||= begin
    input = read_file(USE_FILE).slice_when { |i, _j| i == '' }.to_a
    grid = input.first[0..-2]
    guide = input.last
    grid_hash = {}
    grid.each_with_index do |row, row_index|
      row = if wide
              row.chars.flat_map { |c| widen(c) }
            else
              row.chars
            end
      row.each_with_index do |cell, col_index|
        coordinate = WarehousePoint.new(col_index, row_index)
        grid_hash[coordinate] = (cell == '.' ? nil : cell)
      end
    end
    warehouse = wide ? ChunkyWarehouse.new(grid_hash) : Warehouse.new(grid_hash)
    instructions = []
    guide.each do |instruction_guide|
      instruction_guide.chars.each do |instruction|
        instructions << case instruction
                        when '^'
                          Point::UP
                        when '>'
                          Point::RIGHT
                        when 'v'
                          Point::DOWN
                        when '<'
                          Point::LEFT
                        end
      end
    end
    Robot.new(warehouse, instructions)
  end
end

robot = data(wide: true)
puts robot.question_1
