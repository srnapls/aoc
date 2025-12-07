# frozen_string_literal: true

# file = File.open('data_files/2023_2_example', 'r')
file = File.open('data_files/2023_2_data', 'r')
data = file.readlines.map(&:chomp)
file.close

grid = data.map do |row|
  row_dup = row.dup
  numbers = row.gsub(/\D/, ' ').split(' ')
  spatial_row = []
  numbers.each do |number|
    index = row_dup.index(number)
    (0..(number.length - 1)).each do |i|
      spatial_row[index + i] = number.to_i
      row_dup[index + i] = '.'
    end
  end

  row.split('').map.with_index do |elem, index|
    if spatial_row[index]
      spatial_row[index]
    else
      elem == '.' ? nil : elem
    end
  end
end

def get_number(grid, x_index, y_index)
  x_size = grid.sample.size
  y_size = grid.size

  grid[y_index][x_index] if (0..(x_size - 1)).include?(x_index) && (0..(y_size - 1)).include?(y_index)
end

def get_part_number1(grid, x_index, y_index)
  number = get_number(grid, x_index, y_index)
  return if number.nil?

  connection = (0..(number.to_s.length - 1)).any? do |x_i|
    adjacents = [get_number(grid, x_index + x_i - 1, y_index - 1),
                 get_number(grid, x_index + x_i,     y_index - 1),
                 get_number(grid, x_index + x_i + 1, y_index - 1),
                 get_number(grid, x_index + x_i - 1,     y_index),
                 get_number(grid, x_index + x_i + 1,     y_index),
                 get_number(grid, x_index + x_i - 1, y_index + 1),
                 get_number(grid, x_index + x_i,     y_index + 1),
                 get_number(grid, x_index + x_i + 1, y_index + 1)]
    adjacents.any? { |v| v.is_a? String }
  end
  connection ? number : nil
end

def get_part_number2(grid, x, y)
  numbers = []
  left_top = get_number(grid, x - 1, y - 1)
  right_top = get_number(grid, x + 1, y - 1)
  above = get_number(grid, x, y - 1)
  if left_top && (left_top == right_top)
    numbers << left_top
    numbers << right_top if above.nil?
  elsif left_top.nil? && right_top.nil?
    numbers << above
  else
    numbers << left_top
    numbers << right_top
  end

  left_bottom = get_number(grid, x - 1, y + 1)
  right_bottom = get_number(grid, x + 1, y + 1)
  below = get_number(grid, x, y + 1)
  if left_bottom && (left_bottom == right_bottom)
    numbers << left_bottom
    numbers << right_bottom if below.nil?
  elsif left_bottom.nil? && right_bottom.nil?
    numbers << below
  else
    numbers << left_bottom
    numbers << right_bottom
  end

  numbers << get_number(grid, x - 1, y)
  numbers << get_number(grid, x + 1, y)
  numbers.compact!
  numbers.size == 2 ? numbers.inject(1, :*) : nil
end

part_numbers = []

# pt 1
grid.each.with_index do |row, y|
  new_row = row.dup
  numbers = data[y].gsub(/\D/, ' ').split(' ').map(&:to_i)
  items = numbers.map do |number|
    ind = new_row.index(number)
    (0..(number.to_s.length - 1)).each do |x_i|
      new_row[ind + x_i] = 0
    end
    ind
  end
  items.each do |item|
    part_numbers << get_part_number1(grid, item, y)
  end
end

pp part_numbers.compact.sum

# pt 2
part_numbers2 = []
grid.each.with_index do |row, y|
  items = row.each_index.select { |i| row[i] == '*' }
  items.each do |item|
    part_numbers2 << get_part_number2(grid, item, y)
  end
end
pp part_numbers2.compact.sum
