# frozen_string_literal: true

require_relative '../generic'
FILE_EXAMPLE = '2024/2/example'
FILE = '2024/2/assignment'

def safe?(row)
  (increasing?(row) || decreasing?(row)) && differ_in_range?(row, 1, 3)
end

def increasing?(row)
  row.sort == row
end

def decreasing?(row)
  row.sort.reverse == row
end

def differ_in_range?(row, min_diff, max_diff)
  row.each_cons(2).all? do |left, right|
    (min_diff..max_diff).include?((left - right).abs)
  end
end

def main_method_a(input)
  input.count { |row| safe?(row) }
end

def main_method_b(input)
  input.count do |row|
    0.upto(row.size).any? do |index|
      orig_row = row.clone
      orig_row.delete_at(index)
      safe?(orig_row)
    end
  end
end

data = read_file(FILE).map { |row| row.split(' ').map(&:to_i) }
puts main_method_a(data)
answer = main_method_b(data)
puts answer
