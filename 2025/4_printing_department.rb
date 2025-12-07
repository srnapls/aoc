# frozen_string_literal: true

require_relative '../generic'
require_relative '../common/grid.rb'


class Department
  attr_reader :grid
  attr_accessor :updated_grid

  PAPER = '@'
  ACCESSIBLE = 'x'
  EMPTY = '.'

  def initialize(grid)
    @grid = Grid.from_matrix(grid)
    @updated_grid = @grid.clone
  end

  def accessible_rolls
    start_grid = prepared_grid
    start_grid.coordinates_for_value(PAPER).each do |roll_coord|
      if accessible_roll?(start_grid, roll_coord)
        @updated_grid.update(roll_coord, ACCESSIBLE)
      end
    end
    @updated_grid.coordinates_for_value(ACCESSIBLE).count
  end

  def eventually_accessible_rolls
    start_rolls = -1
    new_rolls = 0
    while start_rolls != new_rolls
      start_grid = prepared_grid
      start_rolls = @updated_grid.coordinates_for_value(ACCESSIBLE).count
      start_grid.coordinates_for_value(PAPER).each do |roll_coord|
        if accessible_roll?(start_grid, roll_coord)
          @updated_grid.update(roll_coord, ACCESSIBLE)
        end
      end
      new_rolls = @updated_grid.coordinates_for_value(ACCESSIBLE).count
      puts new_rolls
    end
    new_rolls
  end

  def accessible_roll?(current_grid, roll_coord)
    count = 0
    current_grid.neighbourhood(roll_coord).each do |coord|
      count += 1 if current_grid[coord] == '@'
      return false if count >= 4
    end
    true
  end

  def to_s = @updated_grid.print_grid

  def prepared_grid
    temp_grid = @updated_grid.clone
    temp_grid.coordinates_for_value(ACCESSIBLE).each do |coord|
      temp_grid.update(coord, EMPTY)
    end
    temp_grid
  end
end

def main_method_a = data.accessible_rolls
def main_method_b = data.eventually_accessible_rolls

def data
  matrix = read_file(assignment_file).map{|row| row.chars}
  Department.new(matrix)
end

puts data
puts '-------'
answer = main_method_b
puts answer
