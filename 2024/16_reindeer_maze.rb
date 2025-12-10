# frozen_string_literal: true

require_relative '../generic'
require_relative '../common/point'
require_relative '../common/grid'
require 'set'

FILE_EXAMPLE = '2024/16/example'
FILE_EXAMPLE_S = '2024/16/example_small'
FILE = '2024/16/assignment'
USE_FILE = FILE

# A class representing the warehouse
class Maze < Grid
  START = 'S'
  END_POINT = 'E'
  WALL = '#'

  attr_accessor :costs
  attr_reader :start_point, :end_point

  def initialize(values)
    super(values)
    @start_point = values_to_coordinates[START].first
    @end_point = values_to_coordinates[END_POINT].first
    @costs = {}
  end

  def neighbours(coord)
    super.reject { |coordinate| wall?(coordinate) }
  end

  def wall?(coordinate)
    values[coordinate] == WALL
  end

  def end?(coordinate)
    values[coordinate] == END_POINT
  end
end

# Class for the reindeer
class Reindeer
  # N: 0
  # E: 1
  # S: 2
  # W: 3
  DIRECTIONS = { 0 => Point::UP,
                 1 => Point::RIGHT,
                 2 => Point::DOWN,
                 3 => Point::LEFT }.freeze

  attr_reader :start_point, :score, :start_pair, :all_visited
  attr_accessor :maze, :costs

  Step = Struct.new(:state, :score, :visited_coords)
  State = Struct.new(:position, :direction)

  def initialize(maze)
    @start_point = maze.start_point
    @start_state = State.new(@start_point, 1)
    @maze = maze
    @score = nil
    @costs = { @start_state => 0 }
    @all_visited = {}
  end

  def question_2
    find_solution
    @all_visited[@score].size
  end

  def question_1
    find_solution
    score
  end

  def start_queue
    queue = []
    unless maze.wall?(start_point.up)
      new_state = State.new(start_point, 0)
      queue << new_step(new_state, 1_000)
      costs[new_state] = 1_000
    end
    unless maze.wall?(start_point.right)
      new_state = State.new(start_point.right, 1)
      queue << new_step(new_state, 1)
      costs[new_state] = 1
    end
    unless maze.wall?(start_point.down)
      new_state = State.new(start_point, 2)
      queue << new_step(new_state, 1_000)
      costs[new_state] = 1_000
    end
    unless maze.wall?(start_point.left)
      new_state = State.new(start_point, 2)
      costs[new_state] = 1_000
      new_state2 = State.new(start_point, 3)
      costs[new_state2] = 2_000
      queue << new_step(new_state2, 2_000)
    end
    queue
  end

  def shortest_path?(current_state, cost)
    @costs.key?(current_state) && @costs[current_state] == cost
  end

  def update_shortest_paths(current_state, cost)
    @costs[current_state] = cost if !@costs.key?(current_state) || cost < @costs[current_state]
  end

  def new_step(state, score, visited_coords = nil)
    visited_coords ||= Set.new([start_point])
    visited = Set.new(visited_coords.to_a)
    visited << state.position
    Step.new(state, score, visited)
  end

  def find_solution
    queue = start_queue
    while queue.any?
      step = queue.shift
      puts queue.size
      next_options(step).each { |new_step| queue << new_step }
    end
  end

  def next_options(current_step)
    to_check = []
    current_state = current_step.state
    position = current_state.position
    direction = current_state.direction
    cost = current_step.score
    
    return [] if @score && cost > @score || !shortest_path?(current_state, cost)

    if maze.end?(position)
      if @score.nil? || current_step.score <= @score
        puts 'yippee'
        @score = current_step.score
        current_score = current_step.score
        @all_visited[current_score] ||= Set.new
        @all_visited[current_score] += Set.new(current_step.visited_coords)
      end
      return []
    end

    move_in_dir = position + DIRECTIONS[direction]
    to_check << add_step(current_step, direction, 1, move_in_dir) if can_visit?(move_in_dir)

    direction = turn(direction)
    to_check << add_step(current_step, direction, 1_000)

    direction = turn(turn(direction))
    to_check << add_step(current_step, direction, 1_000)

    to_check
  end

  def add_step(current_step, direction, score, position = nil)
    position ||= current_step.state.position
    new_score = current_step.score + score
    new_state = State.new(position, direction)
    update_shortest_paths(new_state, new_score)
    new_step(new_state, new_score, current_step.visited_coords)
  end

  def can_visit?(coordinate)
    !maze.wall?(coordinate) && maze.in_grid([coordinate])
  end

  def turn(direction)
    (direction + 1) % 4
  end
end

# wide is used for part 2
def data
  values = {}
  read_file(USE_FILE).each_with_index.map do |row, j|
    row.chars.each_with_index.map do |cell, i|
      values[Point.new(i, j)] = cell
    end
  end
  maze = Maze.new(values)
  Reindeer.new(maze)
end

reindeer = data
puts reindeer.question_2
