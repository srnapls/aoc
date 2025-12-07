# frozen_string_literal: true

# file = File.open('data_files/2023/examples/6_example', 'r')
file = File.open('data_files/2023/data/6_data', 'r')
data = file.readlines.map(&:chomp)
file.close

class Game
  attr_accessor :hands

  # :nodoc:
  def initialize(hands)
    @hands = hands
  end

  def print
    hands.sample(10).sort.each do |hand|
      !pp hand.to_s
    end
  end

  # @return [Integer]
  def total_winning
    hands.sort.map.with_index do |hand, index|
      hand.bid * (index + 1)
    end.inject(0, :+)
  end
end

class Hand
  attr_reader :cards, :bid, :type

  def initialize(cards, bid)
    @cards = cards.map { |card| Card.new(card) }
    @bid = bid
    @type = determine_type2
  end

  # Determines the type of hand
  # 'AAAAA' : five of a kind  -> 6
  # 'AAAAQ' : four of a kind  -> 5
  # '23332' : full house      -> 4
  # 'TTT98' : three of a kind -> 3
  # '23432' : two pair        -> 2
  # 'A23A4' : one pair        -> 1
  # '62345' : high card       -> 0
  def determine_type
    case sorted_cards.length
    when (1..2)
      sorted_cards[0].length + 1
    when 3
      sorted_cards[0].length
    else
      sorted_cards[0].length - 1
    end
  end

  # Determines the type -- now WITH jokers
  def determine_type2
    case determine_type
    when 6 then 6
    when 5 then number_of_jokers.positive? ? 6 : 5
    when 4 then number_of_jokers.positive? ? 6 : 4
    when 3 then number_of_jokers.positive? ? 5 : 3
    when 2
      if number_of_jokers.positive?
        3 + number_of_jokers
      else
        2
      end
    when 1 then number_of_jokers.positive? ? 3 : 1
    else number_of_jokers
    end
  end

  def number_of_jokers
    cards.select { |card| card == 'J' }.size
  end

  # @return [<Array<Card>>]
  def sorted_cards
    cards.sort
         .slice_when { |i, j| i != j }
         .sort_by(&:length)
         .reverse
  end

  def <=>(other)
    return type <=> other.type if type != other.type

    cards.zip(other.cards).each do |card, other_card|
      return card <=> other_card if card != other_card
    end
    0
  end

  def to_s
    "#{cards.map(&:to_s).join('')}  #{bid} - type: #{type}"
  end
end

# Card class
class Card
  attr_reader :face, :value

  def initialize(face)
    @face = face
    @value = case face
             when 'T' then 10
             when 'J' then 1 # originally 11
             when 'Q' then 12
             when 'K' then 13
             when 'A' then 14
             else
               face.to_i
            end
  end

  # @return [Integer]
  def <=>(other)
    value <=> other.value
  end

  def to_s
    face
  end

  def ==(other)
    face == if other.is_a? String
              other
            else
              other.face
            end
  end

  def !=(other)
    !(self == other)
  end
end

hands = data.map do |line|
  info = line.split(' ')
  Hand.new(info[0].split(''), info[1].to_i)
end

game = Game.new(hands)
game.print
!pp game.total_winning
