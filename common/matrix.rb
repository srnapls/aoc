# frozen_string_literal: true

# represents a Matrix
class Matrix
  attr_accessor :grid

  def initialize(grid, default: '')
    @grid = grid
    @default = default
  end

  def value(x, y)
    if x.negative? || y.negative? || x >= width || y >= length
      @default
    else
      grid[y][x]
    end
  end

  def new_value(x, y, value)
    grid[y][x] = value
  end

  def width
    grid.size
  end

  def length
    grid.first.size
  end

  def coordinates(value)
    coords = []
    grid.each_with_index do |row, y|
      row.each_with_index do |cell, x|
        coords << [x,y] if value == cell
      end
    end
    coords
  end

  def values
    grid.flat_map do |row|
      row.map do |value|
        value
      end.uniq
    end.uniq
  end

  def to_s
    grid.map { |row| row.join('') }.join("\n")
  end
end
