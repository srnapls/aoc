# frozen_string_literal: true

require_relative '../generic'
require_relative '../common/point'
require_relative '../common/grid'
require 'set'

FILE_EXAMPLE = '2024/14/example'
FILE = '2024/14/assignment'
USE_FILE = FILE

# class for RobotGrid
class RobotGrid < Grid
  class << self
    def from_width_height(width, height)
      grid_hash = {}
      width.times.each do |x|
        height.times.each do |y|
          grid_hash[Point.new(x, y)] = []
        end
      end
      new(grid_hash)
    end
  end

  def value(x, y)
    val = values[Point.new(x, y)]
    if val.empty?
      '.'
    else
      val.size
    end
  end

  def to_file
    string = ''.dup
    (0...y_size).each do |y|
      (0...x_size).each do |x|
        string << value(x, y).to_s
      end
      string << "\n"
    end
    string
  end

  def update_values_to_coordinates
    @values_to_coordinates =
      @values.group_by { |_key, value| value.size }.transform_values { |val| val.map(&:first) }
  end
end

# class for RobotField
class RobotField
  attr_accessor :grid, :robots, :width, :height, :original_grid

  def initialize(width, height, robots)
    @grid = RobotGrid.from_width_height(width, height)
    @original_grid = @grid.clone
    @width = width
    @height = height
    @robots = robots
  end

  def move_nr_of_times(times)
    @robots.each do |robot|
      new_coord = robot.move_nr_of_times(times, width, height)
      arr_robots = grid.values[new_coord]
      arr_robots << robot
      grid.update(new_coord, arr_robots)
    end
  end

  def question_1
    move_nr_of_times(100)
    safety_factor
  end

  def question_2
    (0..10_000).each do |nr|
      count = 10 + (nr * width)
      if (count - 70) % height != 0
        next
      end

      move_nr_of_times(count)
      File.write("tmp/grid_#{count}.txt", grid.to_file)
      puts count
      @grid = RobotGrid.from_width_height(width, height)
      exit!
    end
  end

  def quadrants
    [select_values_from_grid(0, width / 2, 0, height / 2),
     select_values_from_grid(width / 2 + 1, width, 0, height / 2),
     select_values_from_grid(0, width / 2, height / 2 + 1, height),
     select_values_from_grid(width / 2 + 1, width, height / 2 + 1, height)]
  end

  def symmetrical?
    top_left = select_coord_from_quadrant(0, width / 2, 0, height / 2)
    top_right = select_coord_from_quadrant(width / 2 + 1, width, 0, height / 2)
    bottom_left = select_coord_from_quadrant(0, width / 2, 0, height / 2)
    bottom_right = select_coord_from_quadrant(width / 2 + 1, width, 0, height / 2)
    symmetrical_quadrants?(top_left, top_right) && symmetrical_quadrants?(bottom_left, bottom_right)
  end

  def symmetrical_quadrants?(quadrant1, quadrant2)
    quadrant1.all? do |coordinate|
      mirrored_coordinate = Point.new(width - 1 - coordinate.x_value, coordinate.y_value)
      quadrant2.include?(mirrored_coordinate)
    end
  end

  def select_coord_from_quadrant(start_x, end_x, start_y, end_y)
    grid.update_values_to_coordinates
    grid.values_to_coordinates.reject {|k, _v| k.zero?}
        .values.flatten.select do |coord|
      (start_x...end_x).include?(coord.x_value) && (start_y...end_y).include?(coord.y_value)
    end
  end

  def safety_factor
    quadrants.map { |quadrant| quadrant.sum }.inject(:*)
  end

  def select_values_from_grid(start_x, end_x, start_y, end_y)
    selection = []
    (start_x...end_x).each do |x|
      (start_y...end_y).each do |y|
        value = grid.value(x, y)
        selection << value if value != '.'
      end
    end
    selection
  end
end

# Class for Robot
class Robot
  attr_accessor :start_position, :velocity

  def initialize(position, velocity)
    @start_position = position
    @velocity = velocity
  end

  def move_nr_of_times(number, width, height)
    new_position = start_position + (Point.new(number, number) * velocity)
    new_x = new_position.x_value % width
    new_y = new_position.y_value % height
    Point.new(new_x, new_y)
  end

end

def data
  read_file(USE_FILE).map do |line|
    numbers = line.split(' ').map do |part|
      sub_part = part.split(',')
      [sub_part.first.split('=').last.to_i, sub_part.last.to_i]
    end

    coordinate = Point.new(numbers.first[0], numbers.first[1])
    velocity = Point.new(numbers.last[0], numbers.last[1])
    Robot.new(coordinate, velocity)
  end
end

HEIGHT = 103
WIDTH = 101

entity = RobotField.new(WIDTH, HEIGHT, data)
puts entity.question_2
