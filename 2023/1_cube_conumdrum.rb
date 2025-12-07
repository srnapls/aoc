# frozen_string_literal: true

file = File.open('data_files/2023_1_data', 'r')
data = file.readlines.map(&:chomp)
file.close

ALLOWED_RED = 12
ALLOWED_GREEN = 13
ALLOWED_BLUE = 14

Game = Struct.new(:id, :red, :blue, :green)

games = []
data.each do |row|
  game_info, cubes = row.split(':')
  id = game_info.gsub('Game ', '').to_i
  max_cubes = cubes.gsub(';', ',')
                   .split(',')
                   .map{ |e| e.split(' ') }
                   .group_by(&:last)
                   .transform_values { |v| v.map(&:first).map(&:to_i).max || 0 }
                   .transform_keys(&:to_sym)
  games << Game.new(id, max_cubes[:red], max_cubes[:blue], max_cubes[:green])
end

allowed_games = games.reject do |game|
  game[:red] > ALLOWED_RED || game[:blue] > ALLOWED_BLUE ||
    game[:green] > ALLOWED_GREEN
end
# pt 1
puts allowed_games.map(&:id).sum

# pt 2
powers = games.map do |game|
  game[:red] * game[:blue] * game[:green]
end

puts powers.sum