# frozen_string_literal: true

require_relative '../generic'
FILE_EXAMPLE = '2025/2/example'
FILE = '2025/2/assignment'

class ProductIdRange
  attr_reader :start_value, :end_value

  def initialize(start_value, end_value)
    @start_value = start_value
    @end_value = end_value
  end

  def invalid_ids_part_1
    (begin_range..end_range).sum do |value|
      new_value = "#{value}#{value}".to_i
      actual_range.include?(new_value) ? new_value : 0
    end
  end

  def begin_range
    return 0 if @start_value < 10

    value_string = @start_value.to_s
    value = value_string.length / 2 - 1
    value_string[0..value].to_i
  end

  def end_range
    value_string = @end_value.to_s
    value = if value_string.length.even?
              value_string.length / 2 - 1
            else
              (value_string.length / 2)
            end
    value_string[0..value].to_i
  end

  def actual_range = (@start_value..@end_value)

  def invalid_ids_part_2 = actual_range.sum {|value| invalid_value?(value) ? value : 0 }

  INVALID_REGEXP = /\A(\d+)\1+\z/.freeze

  def invalid_value?(value) = value.to_s.match?(INVALID_REGEXP)
end

def main_method_a = data.sum { |range| range.invalid_ids_part_1 }

def main_method_b = data.sum { |range| range.invalid_ids_part_2 }

def data
  read_file(assignment_file).first.split(',').map do |value|
    ProductIdRange.new(*value.split('-').map(&:to_i))
  end
end

answer = main_method_b
puts answer
