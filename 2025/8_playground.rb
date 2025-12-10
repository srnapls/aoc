# frozen_string_literal: true

require_relative '../generic'
require_relative '../common/coordinate'
require 'set'

class Playground
  attr_reader :coordinates

  def initialize(coordinates)
    @coordinates = coordinates
    @distances = {}
    @circuits = Set.new
  end

  def largest_circuits(countdown)
    sort_coordinates!
    sorted_pairs = @distances.to_a.sort_by(&:last).map(&:first)
    countdown.times do |int|
      shortest_path = @distances.values.min
      pair = sorted_pairs.shift
      break if pair.nil?

      existing_circuits = @circuits.select {|circuit| pair.any? {|coord| circuit.include?(coord)}}
      case existing_circuits.size
      when 0 then @circuits << pair
      when 1 then existing_circuits.first.merge(pair)
      else
        to_add = existing_circuits[1]
        existing_circuits.first.merge(existing_circuits[1])
        @circuits.delete(to_add)
      end
      @distances.delete(pair)
    end
    @circuits.map(&:size).sort.reverse
  end

  private

  def sort_coordinates!
    @coordinates.combination(2).each do |coord1, coord2|
      @distances[[coord1, coord2].to_set] = coord1.euclidean_distance(coord2)
    end
  end
end

def main_method_a
  data.largest_circuits(1000).take(3).inject(1, :*)
end

def data
  coordinates = file.map{|row| Coordinate.new(row.split(',').map(&:to_i))}
  Playground.new(coordinates)
end

def file
  read_file(assignment_file)
end

answer = main_method_a
puts answer
