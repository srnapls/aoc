# frozen_string_literal: true

file = File.open('data_files/hill_climbing', 'r')
data = file.readlines.map(&:chomp).map { |l| l.split('') }
file.close

# hill
class Hill
  attr_accessor :layout

  DIR = { 'up' => [1, 0],
         'down' => [-1, 0],
         'left' => [0, -1],
         'right' => [0, 1] }.freeze

  def initialize(layout:)
    @layout = layout
  end

  def start_coor
    @start ||= begin
      j = nil
      i = @layout.find_index do |row|
        j = row.find_index { |s| s == 'S' }
      end
      [i, j]
    end
  end

  def can_move?(current, div)
    new_coor = move(current, *div)
    return false unless in_grid?(new_coor)

    current_h = height(current)
    new_h = height(new_coor)
    current_h + 1 == new_h || current_h >= new_h
  end

  def in_grid?(coor)
    (0..(@layout.size - 1)).include?(coor.first) &&
      (0..(@layout[0].size - 1)).include?(coor.last)
  end

  def move(current, div_x, div_y)
    [div_x + current.first, div_y + current.last]
  end

  def height(coor)
    h = @layout[coor.first][coor.last]
    case h
    when 'S'
      'a'.ord - 1
    when 'E'
      'z'.ord
    else
      h.ord
    end
  end

  def finish?(coor)
    @layout[coor.first][coor.last] == 'E'
  end

  def all_starting_points
    all_a = []
    @layout.each.with_index do |row, i|
      row.each.with_index do |level, j|
        all_a << [i, j] if %w[a S].include?(level)
      end
    end
    all_a
  end

  def scenic_route_length
    all_starting_points.map {|a_coor| find_solution_length(a_coor)}.compact.min
  end

  def find_solution_length(start)
    queue = [start]
    dist = { start => 0 }

    while queue.any?
      current_coor = queue.min { |a, b| dist[a] <=> dist[b] }

      current_coor = queue.delete(current_coor)
      return dist[current_coor] if finish?(current_coor)

      queue, dist = add_new_coords(current_coor, queue, dist)
    end
  end

  def add_new_coords(current_coor, queue, dist)
    DIR.each_value do |dir|
      next unless can_move?(current_coor, dir)

      new_coor = move(current_coor, *dir)
      next if dist.key?(new_coor)

      queue << new_coor
      dist[new_coor] = dist[current_coor] + 1
    end
    [queue, dist]
  end
end

hill = Hill.new(layout: data)
puts hill.scenic_route_length

