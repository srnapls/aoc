# frozen_string_literal: true

# file = File.open('data_files/2023/examples/7_example', 'r')
# file = File.open('data_files/2023/examples/7_example2', 'r')
# file = File.open('data_files/2023/examples/7_example3', 'r')
file = File.open('data_files/2023/data/7_data', 'r')
data = file.readlines.map(&:chomp)
file.close

class Wasteland
  attr_reader :instructions, :routes

  def initialize(instructions, routes)
    @instructions = instructions
    @routes = routes
  end

  def length_of_route
    start = 'AAA'
    finish = 'ZZZ'
    length = 0
    current_position = start
    loop do
      current_position = next_position(length, current_position)
      length += 1
      return length if current_position == finish
    end
  end

  def next_position(length, current_position)
    instruction = instructions[length % instructions.length]
    routes[current_position][instruction == 'L' ? 0 : 1]
  end

  def length_of_sandstorm_route
    start_positions = routes.keys.select { |pos| pos[-1] == 'A' }
    end_positions = routes.keys.select { |pos| pos[-1] == 'Z' }
    lenghts = start_positions.map do |start_position|
      length = 0
      current_position = start_position
      loop do
        current_position = next_position(length, current_position)
        length += 1
        break length if end_positions.include?(current_position)
      end
    end.inject(1, :lcm)
  end
end

instructions = data[0]
routes = data[1..].reject(&:empty?).to_h do |row|
  next if row == ''

  key, paths = row.split(' = ')
  [key, paths.gsub(/\W/, ' ').split(' ')]
end

wastelands = Wasteland.new(instructions, routes)
!pp wastelands.length_of_sandstorm_route
