# frozen_string_literal: true

require_relative '../common/point'
require_relative '../common/grid'
require 'set'

# file = File.open('data_files/2023/examples/9_example', 'r')
# file = File.open('data_files/2023/examples/9_example2', 'r')
# file = File.open('data_files/2023/examples/9_example3', 'r')
# file = File.open('data_files/2023/examples/9_example4', 'r')
file = File.open('data_files/2023/data/9_data', 'r')
data = file.readlines.map(&:chomp)
file.close

# :nodoc:
class PipeMaze < Grid
  SNAKE_PARTS = %w[| - L J 7 F S].freeze

  attr_accessor :loop_coordinates
  attr_reader :start_point

  def initialize(values)
    super(values)
    @start_point = values.key('S')
    # values[@start_point] = 'F' #example 2 and 3
    # values[@start_point] = '7' #example 4
    values[@start_point] = 'J'
    @loop_coordinates = Set[start_point]
    determine_loop
    add_tiles
  end

  # @overload neighbours()
  def neighbours(coord)
    candidates = case values[coord]
                 when '|' then [coord.up, coord.down]
                 when '-' then [coord.left, coord.right]
                 when 'L' then [coord.up, coord.right]
                 when 'J' then [coord.up, coord.left]
                 when '7' then [coord.left, coord.down]
                 when 'F' then [coord.right, coord.down]
                 when '.' then []
                 when 'S' then coord.neighbours
                 end
    in_grid(candidates)
  end

  def snake_neighbours(coord)
    neighbours(coord).select { |n_coords| SNAKE_PARTS.include?(values[n_coords]) }
  end

  def connected?(start_coord, end_coord)
    snake_neighbours(start_coord).include?(end_coord) &&
      snake_neighbours(end_coord).include?(start_coord)
  end

  def connected_neighbours(coord)
    snake_neighbours(coord).select{ |neighbour| connected?(coord, neighbour) }
  end

  def update_field(coordinate)
    return if @loop_coordinates.include?(coordinate)

    values[coordinate] = '*'
  end

  def determine_loop
    current_position = connected_neighbours(start_point).sample
    loop do
      @loop_coordinates << current_position
      current_position =
        connected_neighbours(current_position).filter_map do |neighbour|
        next if @loop_coordinates.include?(neighbour)

        neighbour
      end.first

      break if current_position.nil?
    end
  end

  # @return [Integer]
  def distance_to_end
    loop_coordinates.size / 2
  end

  def add_tiles
    options = { 0 => 'inside',
                1 => 'outside',
                2 => 'lower_bound',
                3 => 'upper_bound' }
    status = options[1]
    (0...y_size).each do |y_index|
      (0...x_size).each do |x_index|
        current_coord = Point.new(x_index, y_index)
        if @loop_coordinates.include?(current_coord)
          case value(x_index, y_index)
          when '|'
            status = status == options[1] ? options[0] : options[1]
          when 'F'
            status = status == options[0] ? options[2] : options[3]
          when 'J'
            status = status == options[3] ? options[0] : options[1]
          when '7'
            status = status == options[3] ? options[1] : options[0]
          when 'L'
            status = status == options[0] ? options[3] : options[2]
          end
        end

        next unless status == options[0]

        update_field(current_coord)
      end
    end

  end

  def number_of_tiles
    values.values.select {|val| val == '*'}.length
  end
end

grid_values = {}
data.each.with_index do |row, y|
  row.split('').each.with_index do |val, x|
    grid_values[Point.new(x, y)] = val
  end
end

grid = PipeMaze.new(grid_values)
grid.print_grid
!pp grid.distance_to_end
!pp grid.number_of_tiles
