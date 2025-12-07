# frozen_string_literal: true

require_relative '../generic'
require_relative '../common/matrix'

FILE_EXAMPLE = '2024/6/example'
FILE = '2024/6/assignment'
USE_FILE = FILE

# A class representing the Guard
class Guard
  # N: 0
  # E: 1
  # S: 2
  # W: 3
  DIRECTIONS = { 0 => [0, -1], 1 => [1, 0], 2 => [0, 1], 3 => [-1, 0] }.freeze

  attr_reader :start_position, :initial_grid
  attr_accessor :grid, :position, :orientation
  attr_accessor :current_route

  def initialize(grid)
    @grid = grid
    @initial_grid = Matrix.new(grid.grid.map(&:clone), default: nil)
    @position = grid.coordinates('^').first
    @start_position = @position.clone
    grid.new_value(*position, '.')
    @orientation = 0
    @current_route = []
  end

  def turn
    @orientation = (@orientation + 1) % 4
  end

  def gallivant
    while @position
      # update the position you're standing on
      grid.new_value(*@position, 'X')
      move
    end
  end

  def move
    new_position = @position.zip(DIRECTIONS[@orientation]).map { |a, b| a + b }
    next_value = grid.value(*new_position)
    case next_value
    when nil then @position = nil # walk off the grid
    when '#' then turn # turn
    else # walk
      @position = new_position
    end
  end

  def positions_to_check
    grid.coordinates('X') - [@start_position]
  end

  def find_cycles
    count = 0
    positions_to_check.count do |pos|
      puts count
      count += 1
      reset_grid!
      grid.new_value(*pos, 'O')
      cycle_move
      cycle_move
      loop do
        break if @position.nil?

        break if @grid.value(*@position) == '+' && @current_route[..-2].include?(@position) && cycle?

        cycle_move
      end

      @position
    end
  end

  def cycle_move
    return if @position.nil?

    new_position = @position.zip(DIRECTIONS[@orientation]).map { |a, b| a + b }
    next_value = grid.value(*new_position)
    case next_value
    when nil then @position = nil # walk off the grid
    when '#', 'O'
      grid.new_value(*@position, '+')
      turn
    else
      @position = new_position
      # update_board
      @current_route << @position
    end
  end

  def reset_grid!
    @position = @start_position.clone
    @orientation = 0
    @grid = Matrix.new(@initial_grid.grid.map(&:clone), default: nil)
    @current_route = [@position]
  end

  def cycle?
    previous_step = @current_route[-2]
    return false if previous_step.nil?

    @current_route[..-3].each_cons(2).include?([previous_step, @position])
  end
end

def data
  @data ||= begin
              input = read_file(USE_FILE).map(&:chars)
              Matrix.new(input, default: nil)
            end
end

guard = Guard.new(data)
guard.gallivant
puts guard.positions_to_check.count

puts guard.find_cycles
