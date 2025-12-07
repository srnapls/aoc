# frozen_string_literal: true

file = File.open('data_files/data', 'r')
data = file.readlines.map(&:chomp)
file.close

byebug
counter = 0
(1..data.length - 1).each do |i|
  counter += 1 if data[i].to_i + data[i+1].to_i + data[i+2].to_i > data[i - 1].to_i + data[i].to_i + data[i+1].to_i
end
puts counter
