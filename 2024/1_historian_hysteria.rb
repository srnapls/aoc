# frozen_string_literal: true

require_relative '../generic'
FILE_EXAMPLE = '2024/1/example'
FILE = '2024/1/assignment'

def main_method_a(input)
  left_input, right_input = input.transpose
  sorted_left = left_input.sort
  sorted_right = right_input.sort
  sorted_left.zip(sorted_right).sum do |left, right|
    (left - right).abs
  end
end

def main_method_b(input)
  left_input, right_input = input.transpose
  left_input.sum do |value|
    right_input.count(value) * value
  end
end

data = read_file(FILE).map{ |row| row.split(' ').map(&:to_i) }
answer = main_method_b(data)
puts answer
