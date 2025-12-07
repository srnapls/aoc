# frozen_string_literal: true

require_relative '../common/coordinate'
require_relative '../common/grid'
require 'set'

# file = File.open('data_files/2023/examples/11_example', 'r')
file = File.open('data_files/2023/data/11_data', 'r')
data = file.readlines.map(&:chomp)
file.close

# :nodoc:
class HotSpring
  attr_accessor :condition, :list

  def initialize(condition, list)
    @condition = condition
    @list = list
  end

  def arrangements
    options = [[]]
    loop do
      new_options = []
      options.each do |option|
        new_value = @condition[option.length]
        if new_value == '?'
          %w[. #].each do |character|
            new_fill = option + [character]
            new_options << new_fill if potentially_valid?(new_fill.join(''))
          end
        else
          new_option = option + [new_value]
          new_options << new_option if potentially_valid?(new_option.join(''))
        end
      end

      options = new_options

      valid_options = done_and_valid(options)
      return valid_options.size if valid_options.any?

      return 0 if options.all? { |arr| arr.length > @condition.length }
    end
  end

  def done_and_valid(arrangements)
    arrangements.select do |arrangement|
      arrangement = arrangement.join('')
      arrangement.length == @condition.length &&
        length_pieces(arrangement) == @list
    end
  end

  def length_pieces(arrangement)
    arrangement.split('.').map(&:length).reject(&:zero?)
  end

  def potentially_valid?(situation)
    new_sizes = length_pieces(situation)
    segments = new_sizes.length
    return false if segments > list.length

    all_before_last = new_sizes[..-2].zip(list).all? do |new_length, length|
      new_length == length
    end

    return false unless all_before_last

    return true if new_sizes.empty?

    if situation[-1] == '.'
      new_sizes.last == list[segments - 1]
    else
      new_sizes.last <= list[segments - 1]
    end
  end
end

springs = data.map do |row|
  condition, list = row.split(' ')
  condition = condition.split('')
  # condition = ([condition] * 5).join('?').split('')
  HotSpring.new(condition, list.split(',').map(&:to_i))
end

def polish_input(condition, list)
  condition.split('.').map(&:length).reject(&:zero?)
end

!pp springs.map(&:arrangements).sum
