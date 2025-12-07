# frozen_string_literal: true

require_relative '../generic'
FILE_EXAMPLE = '2025/1/example'
FILE = '2025/1/assignment'

def main_method_a(input)
  current = 50
  input.map! do |dir, amount|
    case dir
    when 'L' then current = (current - amount) % 100
    when 'R' then current = (current + amount) % 100
    end
    current
  end
  input.count(0)
end

def main_method_b(input)
  current = 50
  password = 0
  input.each do |dir, amount|
    case dir
    when 'L'
      to_move = current - amount
      while to_move < 0
        password += 1
        to_move += 100
      end
    when 'R'
      to_move = current + amount
      while to_move >= 100
        password += 1
        to_move -= 100
      end
    end
    current = to_move
  end
  password
end

data = read_file(FILE).map{ |row| [row.slice!(0), row.to_i]}
answer = main_method_b(data)
puts answer
