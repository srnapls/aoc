# frozen_string_literal: true

require_relative '../generic'
require_relative '../common/grid.rb'

class Compactor
  attr_reader :problems, :operator

  def initialize(problems, operator)
    @problems = problems
    @operator = operator
  end

  def answer
    @problems.map {|row| row_value(row)}
             .inject(fmap_value, @operator.to_sym)
  end

  def fmap_value = @operator == '+' ? 0 : 1

  def cephalopod_answer
    @problems.transpose
             .map {|row| row_value(row)}
             .inject(fmap_value, @operator.to_sym)
  end

  def row_value(row)
    row.uniq == [' '] ? fmap_value : row.join('').to_i
  end
end

def main_method_a = data.sum(&:answer)
def main_method_b = data.sum(&:cephalopod_answer)

def data
  file_data = prep_file_data
  operators = file_data.pop
  dividers = operators.chars.filter_map.with_index do |value, index|
    index - 1 if value != ' ' && index != 0
  end
  # add index 0 to the beginning and max_length to the end
  dividers.unshift(0)
  dividers << file_data.first.length
  all_ranges = Array.new(dividers.size + 1) {[]}
  file_data.each do |row|
    dividers.each_cons(2).with_index do |range, divider_index|
      start_range, end_range = range
      all_ranges[divider_index] << row.chars[start_range..end_range]
    end
  end
  operators.split(' ').zip(all_ranges).map do |operator, ranges|
    Compactor.new(ranges, operator)
  end
end

def prep_file_data
  # add spaces to the end to all lines are equal length
  max_length = file.map(&:length).max
  file.map do |row|
    padding = (max_length - row.length).times.map{' '}.join('')
    "#{row}#{padding}"
  end
end

def file = read_file(assignment_file)

puts '-------'
answer = main_method_b
puts answer
