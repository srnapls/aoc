# frozen_string_literal: true

require_relative '../common/coordinate'
require_relative '../common/grid'
require 'set'

# file = File.open('data_files/2023/examples/10_example', 'r')
file = File.open('data_files/2023/data/10_data', 'r')
data = file.readlines.map(&:chomp)
file.close

# :nodoc:
class CosmicSpace < Grid
  attr_accessor :empty_rows, :empty_columns

  def initialize(grid)
    @empty_rows = empty_indices(grid)
    @empty_columns = empty_indices(grid.transpose)
    super(filled_space(grid))
  end

  def sum_short_paths
    galaxy_pairs.map do |pair|
      calculate_distance(*pair)
    end.sum
  end

  def calculate_distance(start_point, end_point)
    base_distance = start_point.distance(end_point)

    extra_distance = 1_000_000

    (start_point.combined_x_range(end_point).to_a & empty_columns).each do |_|
      base_distance += extra_distance - 1
    end

    (start_point.combined_y_range(end_point).to_a & empty_rows).each do |_|
      base_distance += extra_distance - 1
    end
    base_distance
  end

  private

  def filled_space(grid)
    fill_empty_space = false
    mapping = {}
    new_grid = fill_empty_space ? expanded_grid(grid) : grid
    new_grid.each.with_index do |row, y_index|
      row.each.with_index do |value, x_index|
        mapping[Coordinate.new(x_index, y_index)] = value
      end
    end
    mapping
  end

  def empty_indices(grid)
    grid.filter_map.with_index do |row, row_index|
      row_index if row.uniq.size == 1 && row.uniq.first == '.'
    end
  end

  def expanded_grid(grid)
    empty_rows.each.with_index do |row_index, number|
      grid.insert(row_index + number + 1, grid[row_index + number])
    end

    grid = grid.transpose
    empty_columns.each.with_index do |col_index, number|
      grid.insert(col_index + number + 1, grid[col_index + number])
    end
    grid.transpose
  end

  def galaxy_coordinates
    @values.select{ |_, v| v == '#' }.keys
  end

  def galaxy_pairs
    pairs = Set.new
    galaxy_coordinates.permutation(2).each do |pair|
      pairs << pair unless pairs.include?(pair.reverse)
    end
    pairs.to_a
  end
end

grid = data.map { |row| row.split('')}
space = CosmicSpace.new(grid)
!pp space.sum_short_paths
