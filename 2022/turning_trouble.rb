# frozen_string_literal: true

file = File.open('data_files/turning_trouble', 'r')
data = file.readlines.map(&:chomp)
file.close

data.first.split('').each_cons(14).with_index do |entry, index|
  if entry.uniq == entry
    puts index + 14
    return
  end
end
