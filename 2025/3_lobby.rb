# frozen_string_literal: true

require_relative '../generic'
FILE_EXAMPLE = '2025/2/example'
FILE = '2025/2/assignment'

class Bank
  attr_accessor :batteries
  attr_accessor :joltage_batteries

  def initialize(batteries)
    @batteries = batteries.clone
    @joltage_batteries = []
  end

  def largest_joltage(size)
    index = -1
    size.times.each do |int|
      values, index = find_max_and_index(index + 1, size - int - 1)
      @joltage_batteries << values
    end
    @joltage_batteries.map.with_index do |value, index|
      10.pow(size - index - 1) * value
    end.sum
  end

  def find_max_and_index(starting_point, offset)
    selected_array = @batteries[starting_point..(- offset - 1)]
    max_value = selected_array.max
    [max_value, starting_point + selected_array.index(max_value)]
  end

  def to_s = @batteries.inspect
end

def main_method_a = data.map {|bank| bank.largest_joltage(2)}
def main_method_b = data.sum {|bank| bank.largest_joltage(12)}

def data
  read_file(assignment_file).map do |row|
    Bank.new(row.split('').map(&:to_i))
  end
end

answer = main_method_b
puts answer
