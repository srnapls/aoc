# frozen_string_literal: true

require_relative '../generic'
require_relative '../common/grid'

class Laboratory
  attr_reader :laser_grid, :height
  attr_accessor :step_grid, :nr_splits, :tachyon_grid

  def initialize(laser_grid)
    @laser_grid = laser_grid
    @step_grid = laser_grid.map(&:clone)
    @tachyon_grid = laser_grid.map(&:clone)
    @nr_splits = 0
    @height = @laser_grid.size
  end

  def proceed(line)
    @step_grid[line].each.with_index do |value, index|
      case value
      when 'S', '|' then update_vertical_beam(line + 1, index)
      when '^'
        # only update if an actual beam hits it
        if @step_grid[line - 1][index] == '|'
          @nr_splits += 1
          update_vertical_beam(line, index - 1)
          update_vertical_beam(line, index + 1)
          update_vertical_beam(line + 1, index - 1)
          update_vertical_beam(line + 1, index + 1)
        else
          @step_grid[line][index] = '.'
        end
      else
        # no-op
      end
    end
  end

  def tachyon_proceed(line)
    @step_grid[line].each.with_index do |value, index|
      case value
      when 'S' then @tachyon_grid[line][index] = 1
      when '|' then @tachyon_grid[line][index] = value_for_pipe(line, index)
      end
      @tachyon_grid[line][index] = 0 unless @tachyon_grid[line][index].is_a?(Integer)
    end
  end

  def value_for_pipe(line, index)
    if @step_grid[line][index - 1] == '^' && @step_grid[line][index + 1] == '^'
      (index - 1..index + 1).sum { |i| @tachyon_grid[line - 1][i] }
    elsif @step_grid[line - 1][index] == '|'
      if @step_grid[line][index - 1] == '^'
        @tachyon_grid[line - 1][index] + @tachyon_grid[line - 1][index - 1]
      elsif @step_grid[line][index + 1] == '^'
        @tachyon_grid[line - 1][index] + @tachyon_grid[line - 1][index + 1]
      else
        @tachyon_grid[line - 1][index]
      end
    elsif @step_grid[line][index - 1] == '^'
      @tachyon_grid[line - 1][index - 1]
    elsif @step_grid[line][index + 1] == '^'
      @tachyon_grid[line - 1][index + 1]
    else
      @tachyon_grid[line - 1][index]
    end
  end

  def print_laser_grid
    print_grid(@laser_grid)
  end

  def print_step_grid
    print_grid(@step_grid)
  end

  def print_grid(grid)
    (0...@height).each do |y|
      puts (0...grid.first.size).map { |x| grid[y][x] }.join('')
    end
  end

  def update_vertical_beam(line_number, index)
    return if line_number >= @height

    @step_grid[line_number][index] = '|' if @step_grid[line_number][index] == '.'
  end

  def nr_of_splits
    @height.times { |line| proceed(line) }
    @nr_splits
  end

  def tachyon_splits
    @height.times { |line| proceed(line) }
    @height.times { |line| tachyon_proceed(line) }
    @tachyon_grid.last.sum { |v| v == '.' ? 0 : v }
  end
end

def main_method_a
  data.nr_of_splits
end

def main_method_b
  data.tachyon_splits
end

def data
  Laboratory.new(file.map(&:chars))
end

def file
  read_file(assignment_file)
end

answer = main_method_b
puts answer
