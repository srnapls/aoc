# frozen_string_literal: true

require 'set'

file = File.open('data_files/rope_bridge', 'r')
data = file.readlines.map(&:chomp).map { |e| e.split(' ') }
file.close

# rope bridge
class Grid
  attr_accessor :rope
  attr_accessor :locations_of_t

  def initialize
    @rope = Array.new(10) { [0, 0] }
    @locations_of_t = Set.new([[0, 0]])
  end

  def x(loc)
    loc[0]
  end

  def y(loc)
    loc[1]
  end

  def update_rope(new_h)
    new_rope = [new_h]
    @rope.each.with_index do |tail, index|
      next if new_rope.size >= index + 1

      new_rope << if update_tail?(tail, new_h)
                    new_location(tail, new_h)
                  else
                    tail
                   end
      new_h = new_rope.last
    end
    @rope = new_rope
    @locations_of_t << @rope.last
  end

  def new_location(current, new_h)
    dist_x = x(new_h) - x(current)
    dist_y = y(new_h) - y(current)
    [x(current) + (dist_x <=> 0), y(current) + (dist_y <=> 0)]
  end

  def distance(current_t, new_h)
    x_t, y_t = current_t
    x_h, y_h = new_h
    (x_t - x_h).abs * (y_t - y_h).abs
  end

  def taxi_cab_distance(current_t, new_h)
    x_t, y_t = current_t
    x_h, y_h = new_h
    (x_t - x_h).abs + (y_t - y_h).abs
  end

  def update_tail?(current_t, new_h)
    current_t != new_h && taxi_cab_distance(current_t, new_h) != 1 &&
      distance(current_t, new_h) != 1
  end

  def up
    new_h = [x(@rope.first), y(@rope.first) + 1]
    update_rope(new_h)
  end

  def down
    new_h = [x(@rope.first), y(@rope.first) - 1]
    update_rope(new_h)
  end

  def right
    new_h = [x(@rope.first) + 1, y(@rope.first)]
    update_rope(new_h)
  end

  def left
    new_h = [x(@rope.first) - 1, y(@rope.first)]
    update_rope(new_h)
  end

  def action(dir, number)
    count = number.to_i
    case dir
    when 'R'
      count.times { right }
    when 'L'
      count.times { left }
    when 'D'
      count.times { down }
    when 'U'
      count.times { up }
    end
  end

  def tail_grid
    max_x = @locations_of_t.map(&:first).max
    max_y = @locations_of_t.map(&:last).max
    (0..max_y).each do |y|
      (0..max_x).each do |x|
        print @locations_of_t.include?([x, max_y - y]) ? '#' : '.'
      end
      puts
    end
  end
end


bridge = Grid.new
data.map{|line| bridge.action(*line)}

puts bridge.locations_of_t.size
