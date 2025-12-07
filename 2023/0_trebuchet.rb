# frozen_string_literal: true

file = File.open('data_files/2023_0_data', 'r')
data = file.readlines.map(&:chomp)
file.close

def get_number(row, part2)
  if part2
    mapping = {
      'one'   => '1',
      'two'   => '2',
      'three' => '3',
      'four'  => '4',
      'five'  => '5',
      'six'   => '6',
      'seven' => '7',
      'eight' => '8',
      'nine'  => '9'
    }
    matchers = mapping.keys.join('|')
    row = row.gsub(/#{matchers}/) do |match|
      "#{mapping[match]}#{match[-1]}"
    end.gsub(/#{matchers}/, mapping)
  end
  numbers = row.gsub(/\D/,"")

  "#{numbers[0]}#{numbers[-1]}".to_i
end

puts data.filter_map{|row| get_number(row, true)}.sum

