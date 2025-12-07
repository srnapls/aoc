# frozen_string_literal: true

require_relative '../generic'
FILE_EXAMPLE = '2024/3/example'
FILE_EXAMPLE2 = '2024/3/example2'
FILE = '2024/3/assignment'
USE_FILE = FILE


REGEX_A = /mul\((?<left>\d+),(?<right>\d+)\)/.freeze

def parse_mults(row)
  row.scan(REGEX_A).map { |match| match.map(&:to_i) }
end

def data_a
  read_file(USE_FILE).map { |row| parse_mults(row) }
end

REGEX_B = /don't\(\).*?do\(\)/.freeze

def data_b
  input = read_file(USE_FILE).join('')
  while REGEX_B.match?(input) do
    input = input.sub(REGEX_B, '')
  end
  input.sub!(/don't\(\).*/, '')
  parse_mults(input)
end

def mult(left, right)
  left * right
end

def main(entry_line)
  entry_line.sum { |values| mult(*values) }
end


number = main(data_b)
puts number
# puts answer
