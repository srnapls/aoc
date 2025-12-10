# frozen_string_literal: true

require_relative '../generic'
require_relative '../common/grid'
require_relative '../common/point'
require 'set'

FILE_EXAMPLE = '2024/10/example'
FILE_EXAMPLE0 = '2024/10/example0'
FILE = '2024/10/assignment'
USE_FILE = FILE_EXAMPLE

# A class representing the topographic hiking map
class TopographicMap < Grid
  attr_accessor :trailhead_scores
  
  def initialize(input)
    values_hash = {}
    input.each_with_index do |row, j|
      row.each_with_index do |value, i|
        values_hash[Point.new(i, j)] = value
      end
    end
    super(values_hash)
    @trailhead_scores = score_trailheads2
  end

  def score_trailheads
    coordinates_for_value(0).to_h do |trailhead|
      [trailhead, score_trailhead(trailhead, 0)]
    end
  end

  def score_trailheads2
    coordinates_for_value(0).to_h do |trailhead|
      [trailhead, score_trailhead2(trailhead, 0)]
    end
  end

  def sum_trailheads
    @trailhead_scores.values.sum(&:count)
  end

  def sum_trailheads2
    @trailhead_scores.values.sum
  end

  def score_trailhead(head, height)
    return head if height == 9

    neighbours(head).filter_map do |neighbour|
      score_trailhead(neighbour, height + 1) if @values[neighbour] == height + 1
    end.flatten.uniq
  end

  def score_trailhead2(head, height)
    return 1 if height == 9

    neighbours(head).sum do |neighbour|
      if @values[neighbour] == height + 1
        score_trailhead2(neighbour, height + 1)
      else
        0
      end
    end
  end

end

def data
  input = read_file(USE_FILE).map do |row|
    row.chars.map do |char|
      char == '.' ? nil : char.to_i
    end
  end
  TopographicMap.new(input)
end

grid = data
puts grid.sum_trailheads2




