# frozen_string_literal: true

require_relative '../generic'
require_relative '../common/grid.rb'


class Cafetaria
  attr_reader :ranges, :ingredients

  def initialize(ranges, ingredients)
    @ranges = ranges
    @ingredients = ingredients
  end

  def to_s = [@ranges.inspect, @ingredients.inspect]

  def fresh_ingredients
    @ingredients.count do |ingredient|
      @ranges.any? {|range| range.include?(ingredient)}
    end
  end

  def actual_fresh_ingredients
    working_ranges = @ranges.dup
    new_ranges = []
    loop do
      new_ranges = simplify_ranges(working_ranges.clone)
      break if new_ranges == working_ranges
      working_ranges = new_ranges
    end

    new_ranges.map(&:size).sum
  end

  def simplify_ranges(working_ranges)
    new_ranges = []
    while working_ranges.any? do
      ranges_to_add, working_ranges = simplify_range(working_ranges, working_ranges.shift)
      new_ranges = new_ranges + ranges_to_add
    end
    new_ranges
  end

  def simplify_range(working_ranges, working_range)
    new_ranges = []
    not_handled_ranges = []
    queue = working_ranges.dup
    while queue.any? do
      range_to_compare = queue.shift
      if working_range.include?(range_to_compare.begin)
        working_range = Range.new(working_range.begin,[working_range.end, range_to_compare.end].max)
        working_ranges.delete(range_to_compare)
      elsif range_to_compare.include?(working_range.begin)
        working_range = Range.new(range_to_compare.begin, [working_range.end, range_to_compare.end].max)
        working_ranges.delete(range_to_compare)
      else
        not_handled_ranges << range_to_compare
      end
    end
    new_ranges << working_range
    [new_ranges, not_handled_ranges]
  end
end

def main_method_a = data.fresh_ingredients
def main_method_b = data.actual_fresh_ingredients

def data
  separator = file.index('')
  ranges = file[0..separator - 1].map do |range|
    Range.new(*range.split('-').map(&:to_i))
  end
  ingredients = file[separator..].map(&:to_i)
  Cafetaria.new(ranges, ingredients)
end

def file = read_file(assignment_file)

puts '-------'
answer = main_method_b
puts answer
