file = File.open('data_files/rucksacks', 'r')
data = file.readlines.map(&:chomp)
file.close

def rugsack2(str)
  middle = str.length / 2
  first = str[0..(middle-1)]
  second = str[middle..-1]
  letter = [first, second].map{ |str| str.split('') }.inject(:&).first
  if letter.ord <= 90
    letter.ord - 'A'.ord + 1 + 26
  elsif letter.ord >= 97
    letter.ord - 'a'.ord + 1
  end
end

def rugsack3(entries)
  letter = entries.map{ |str| str.split('') }.inject(:&).first
  if letter.ord <= 90
    letter.ord - 'A'.ord + 1 + 26
  elsif letter.ord >= 97
    letter.ord - 'a'.ord + 1
  end
end

number2 = data.map do |str|
  rugsack2(str)
end.sum

number3 = data.each_slice(3).map do |entries|
  rugsack3(entries)
end.sum

puts number3
