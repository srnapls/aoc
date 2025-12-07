# frozen_string_literal: true

file = File.open('data_files/elfs_data', 'r')
data = file.readlines.map(&:chomp)
file.close

singular_elf = []
calories_sum = []
data.each do |entry|
  if entry.empty?
    calories_sum << singular_elf.sum
    singular_elf = []
  else
    singular_elf << entry.to_i
  end
end

puts calories_sum.sort.reverse[0..2].sum
