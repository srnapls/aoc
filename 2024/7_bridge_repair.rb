# frozen_string_literal: true

require_relative '../generic'
require_relative '../common/matrix'

FILE_EXAMPLE = '2024/7/example'
FILE = '2024/7/assignment'
USE_FILE = FILE

# A class representing the Guard
class Equation
  OPERATIONS = [->(a, b) { a + b },
                ->(a, b) { a * b },
                ->(a, b) { (a.to_s + b.to_s).to_i }].freeze # last one added for part 2

  attr_reader :result, :digits

  def initialize(result, digits)
    @result = result
    @digits = digits
  end

  def calibration_result
    has_solution = OPERATIONS.repeated_permutation(@digits.size - 1).any? do |operations|
      is_solution?(operations, @digits.clone)
    end
    has_solution ? result : 0
  end

  def is_solution?(operations, digits)
    start = digits.shift
    number_result = [digits, operations].transpose.inject(start) do |sum, elem|
      return false if sum > @result

      digit, operation = elem
      operation.call(sum, digit)
    end
    number_result == @result
  end

  def inspect
    "#{@result}: #{@digits.inspect}"
  end
end

def data
  input = read_file(USE_FILE)
  input.map do |line|
    temp = line.split(':')
    digits = temp.last.split(' ').map(&:to_i)
    Equation.new(temp.first.to_i, digits)
  end
end

result = data.map(&:calibration_result).sum
puts result
