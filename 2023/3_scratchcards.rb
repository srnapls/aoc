# frozen_string_literal: true

# file = File.open('data_files/2023/examples/3_example', 'r')
file = File.open('data_files/2023/data/3_data', 'r')
data = file.readlines.map(&:chomp)
file.close

Card = Struct.new(:id, :winning_numbers, :numbers, :copies, :points, :matchers)
cards = []

# Read cards
data.each do |row|
  card_nr, card_numbers = row.split(':')
  id = card_nr.gsub('Card ', '').to_i
  winning_numbers, numbers =
    card_numbers.split('|')
                .map { |e| e.split(' ').map(&:to_i) }
  cards << Card.new(id, winning_numbers, numbers, 1)
end

# pt 1
cards.each do |card|
  winning_numbers = card.winning_numbers
  numbers = card.numbers
  matchers = numbers.size - (numbers - winning_numbers).size
  card.matchers = matchers
  card.points = matchers.zero? ? 0 : 2.pow(matchers - 1)
end

!pp cards.map(&:points).sum

# pt 2
cards.each.with_index do |card, index|
  (1..card.matchers).each do |offset|
    cards[index + offset].copies += card.copies
  end
end

!pp cards.map(&:copies).sum
