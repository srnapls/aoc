# frozen_string_literal: true

require_relative '../common/coordinate'
require_relative '../common/grid'
require 'set'

file = File.open('data_files/2023/examples/13_example', 'r')
# file = File.open('data_files/2023/data/13_data', 'r')
data = file.readlines.map(&:chomp)
file.close

# :nodoc:
class Platform
  attr_accessor :space
  attr_reader :orig_space

  def initialize(space)
    @space = space.dup
    @orig_space = space.dup
  end

  def cycle
    @space = shift_north
    @space = shift_west
    @space = shift_south
    @space = shift_east
  end

  def detect_cycle
    cycles = []
    loop do
      cycles << @space
      @space = cycle
      return determine_cycle(cycles, @space) if cycles.include?(@space)
    end
  end

  def determine_cycle(cycles, current_status)
    index = cycles.find_index(current_status)
    !pp "INDEX" + index.to_s
    [index, cycles.length - 1 - index]
  end

  def cycle_score
    count = 1_000_000_000
    start_point, cycle_length = detect_cycle
    @space = @orig_space
    (count % (cycle_length - start_point) + start_point).times do
      cycle
    end
    score
  end

  def shift_up(platform)
    platform.map do |column|
      sections = column.slice_when { |i, _j| i == '#' }.to_a
      sections.map do |section|
        balls = section.count('O')
        spaces = section.count('.')
        stoppers = section.count('#')
        ['O'] * balls + ['.'] * spaces + ['#'] * stoppers
      end.flatten(1)
    end
  end

  def shift_down(platform)
    platform.map do |column|
      sections = column.slice_when { |i, _j| i == '#' }.to_a
      sections.map do |section|
        balls = section.count('O')
        spaces = section.count('.')
        stoppers = section.count('#')
        ['.'] * spaces + ['O'] * balls + ['#'] * stoppers
      end.flatten(1)
    end
  end

  def shift_north
    shift_up(space.transpose).transpose
  end

  def shift_west
    shift_up(space)
  end

  def shift_south
    shift_down(space.transpose).transpose
  end

  def shift_east
    shift_down(space)
  end

  def print_space
    @space.each do |items|
      puts items.join('')
    end
    puts ''
  end

  def score_north
    @space = shift_north
    score
  end

  def score
    nr_of_rows = space.length
    space.map.with_index do |row, index|
      row.count('O') * (nr_of_rows - index)
    end.sum
  end
end

platform = data.map { |row| row.split('') }
platform = Platform.new(platform)
!pp platform.cycle_score
platform.print_space

