# frozen_string_literal: true

require_relative '../generic'
require_relative '../common/matrix'

FILE_EXAMPLE = '2024/4/example'
FILE = '2024/4/assignment'
USE_FILE = FILE

MAS = 'MAS'
XMAS = 'XMAS'

def data
  @data ||= begin
              input = read_file(USE_FILE).map(&:chars)
              Matrix.new(input)
            end
end

def horizontal_check(grid, coord)
  x, y = coord
  str1 = (0...4).map { |i| grid.value(x + i, y) }.join('')
  str2 = (0...4).map { |i| grid.value(x - i, y) }.join('')

  @xmas_counter += 1 if str1 == XMAS
  @xmas_counter += 1 if str2 == XMAS
end

def vertical_check(grid, coord)
  x, y = coord
  str1 = (0...4).map { |i| grid.value(x, y + i) }.join('')
  str2 = (0...4).map { |i| grid.value(x, y - i) }.join('')

  @xmas_counter += 1 if str1 == XMAS
  @xmas_counter += 1 if str2 == XMAS
end

def diagonal_check(grid, coord)
  x, y = coord
  str1 = (0...4).map { |i| grid.value(x + i, y + i) }.join('')
  str2 = (0...4).map { |i| grid.value(x + i, y - i) }.join('')
  str3 = (0...4).map { |i| grid.value(x - i, y + i) }.join('')
  str4 = (0...4).map { |i| grid.value(x - i, y - i) }.join('')

  @xmas_counter += 1 if str1 == XMAS
  @xmas_counter += 1 if str2 == XMAS
  @xmas_counter += 1 if str3 == XMAS
  @xmas_counter += 1 if str4 == XMAS
end

def xmas_check(grid, coord)
  horizontal_check(grid, coord)
  vertical_check(grid, coord)
  diagonal_check(grid, coord)
end

def crossed_mas_check(grid, coord)
  x, y = coord
  # (0,0) + (1,1) + (2,2)
  # (2,0) + (1,1) + (0,2)
  str1 = (0...3).map { |i| grid.value(x - 1 + i, y - 1 + i) }.join('')
  str2 = (0...3).map { |i| grid.value(x + 1 - i, y - 1 + i) }.join('')
  if [str1, str1.reverse].include?(MAS) && [str2, str2.reverse].include?(MAS)
    @crossed_mas_counter += 1
  end
end

@xmas_counter = 0
@crossed_mas_counter = 0
data.coordinates('X').each { |coord| xmas_check(data, coord) }
data.coordinates('A').each { |coord| crossed_mas_check(data, coord) }
puts @xmas_counter
puts @crossed_mas_counter
