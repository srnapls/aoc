# frozen_string_literal: true

file = File.open('data_files/rock_paper_scissors', 'r')
data = file.readlines.map(&:chomp)
file.close

SCORE1 = {'X' => 1,
         'Y' => 2,
         'Z' => 3 }.freeze

SCORE2 = {'X' => 0,
          'Y' => 3,
          'Z' => 6}.freeze

def match_score1(entry)
  opponent_nr = entry.first
  own_nr = entry[1]

  case opponent_nr
  when 'A' # rock
    { 'X' => 3,
      'Y' => 6,
      'Z' => 0 }.fetch(own_nr)
  when 'B' # paper
    { 'X' => 0,
      'Y' => 3,
      'Z' => 6 }.fetch(own_nr)
  when 'C' # scissors
    { 'X' => 6,
      'Y' => 0,
      'Z' => 3 }.fetch(own_nr)
  end
end

def rps(entry) #return total score
  opponent_nr = entry.first
  fate = entry[1]

  # X means lose
  # Y means draw
  # Z means win
  case opponent_nr
  when 'A' # rock
    { 'X' => 'Z',
      'Y' => 'X',
      'Z' => 'Y' }.fetch(fate)
  when 'B' # paper
    { 'X' => 'X',
      'Y' => 'Y',
      'Z' => 'Z' }.fetch(fate)
  when 'C' # scissors
    { 'X' => 'Y',
      'Y' => 'Z',
      'Z' => 'X' }.fetch(fate)
  end
end

scores1 = data.map(&:split).map do |entry|
  SCORE1[entry[1]] + match_score1(entry)
end

scores2 = data.map(&:split).map do |entry|
  SCORE2[entry[1]] + SCORE1[rps(entry)]
end

puts scores2.sum
