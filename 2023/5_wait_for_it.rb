# frozen_string_literal: true

# file = File.open('data_files/2023/examples/5_example', 'r')
file = File.open('data_files/2023/data/5_data', 'r')
data = file.readlines.map(&:chomp)
file.close

times = data[0].gsub('Time:', '').split(' ').map(&:to_i)
distances = data[1].gsub('Distance:', '').split(' ').map(&:to_i)

# :nodoc:
class Game
  attr_reader :time, :distance_to_beat

  def initialize(time, distance)
    @time = time
    @distance_to_beat = distance
  end

  def winning_games
    won = 0
    (0..(time / 2)).each do |hold|
      won += 1 if hold * (time - hold) > distance_to_beat
    end
    (time % 2).zero? ? won * 2 - 1 : won * 2
  end
end

games = times.zip(distances).map do |time, dist|
  Game.new(time, dist)
end

# !pp games.map(&:winning_games).inject(1, :*)

time = data[0].gsub('Time:', '').split(' ').join('').to_i
distance = data[1].gsub('Distance:', '').split(' ').join('').to_i

!pp Math.sqrt(time * time - 4 * distance).floor
!pp distance
!pp Game.new(time, distance).winning_games