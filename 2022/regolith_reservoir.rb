# frozen_string_literal: true

file = File.open('data_files/regolith_reservoir', 'r')
data = file.readlines.map(&:chomp).compact
file.close

data.map! do |line|
  line.split(' -> ').map { |l| l.split(',').map(&:to_i) }
end

# cave
class Cave
  attr_accessor :structure
  attr_accessor :hole
  attr_accessor :sand_grains
  attr_accessor :current_grain

  def initialize(format)
    @structure = CaveParser.parse_format(format)
    @hole = find_hole
    @sand_grains = 0
    @current_grain = @hole.clone
  end

  def find_hole
    [@structure[0].find_index('X'), 0]
  end

  def let_loose_till_void
    @sand_grains += 1 while drop_grain_till_void(*@hole)
  end

  def let_loose
    @structure << (Array.new(@structure.first.size) { '.' })
    @structure << (Array.new(@structure.first.size) { '#' })
    @structure[@hole.last][@hole.first] = '.'
    while drop_grain
      @sand_grains += 1
      @current_grain = @hole.clone
    end
  end

  def drop_grain_till_void(x_coor, y_coor)
    if off_grid?(x_coor, y_coor + 1)
      false
    elsif free?(x_coor, y_coor + 1)
      drop_grain_till_void(x_coor, y_coor + 1)
    elsif off_grid?(x_coor - 1, y_coor + 1)
      false
    elsif free?(x_coor - 1, y_coor + 1)
      drop_grain_till_void(x_coor - 1, y_coor + 1)
    elsif off_grid?(x_coor + 1, y_coor + 1)
      false
    elsif free?(x_coor + 1, y_coor + 1)
      drop_grain_till_void(x_coor + 1, y_coor + 1)
    else
      @structure[y_coor][x_coor] = 'o'
      true
    end
  end
  
  def current_x
    @current_grain.first
  end
  
  def current_y
    @current_grain.last
  end
  
  def drop_grain
    if @structure[current_y][current_x] == 'o' && @current_grain == @hole
      false
    elsif free_ignore_nil?(current_x, current_y + 1)
      @current_grain = [current_x, current_y + 1]
      drop_grain
    elsif free_ignore_nil?(current_x - 1, current_y + 1)
      @current_grain = [current_x - 1, current_y + 1]
      drop_grain
    elsif free_ignore_nil?(current_x + 1, current_y + 1)
      @current_grain = [current_x + 1, current_y + 1]
      drop_grain
    else
      @structure[current_y][current_x] = 'o'
      true
    end
  end

  def add_room(x_coor, y_coor)
    if x_coor.negative?
      @structure.map! { |row| row.unshift('.') }
      @structure[@structure.size - 1][0] = '#'
      @current_grain = [current_x + 1, current_y]
      @hole = [@hole.first + 1, @hole.last]
      x_coor = 0
    end

    if x_coor >= @structure.first.size
      @structure.map! { |row| row << '.' }
      @structure[@structure.size - 1][@structure.first.size - 1] = '#'
    end

    return nil if y_coor >= @structure.size

    [x_coor, y_coor]
  end

  def off_grid?(x_coor, y_coor)
    y_coor >= @structure.size || x_coor.negative? ||
      x_coor >= @structure.first.size
  end

  def free?(x_coor, y_coor)
    @structure[y_coor][x_coor] == '.'
  end

  def free_ignore_nil?(x_coor, y_coor)
    coords = add_room(x_coor, y_coor)
    return false if coords.nil?

    free?(*coords)
  end

  def to_s
    @structure.each do |line|
      !pp line.join('')
    end
  end
end

# Make the input managable
class CaveParser
  class << self
    def parse_format(format)
      grid = []
      format.each do |instructions|
        instructions.each_cons(2) do |start_point, end_point|
          grid = if start_point.first == end_point.first
                   draw_vert_line(start_point.first, [start_point.last, end_point.last], grid)
                 else
                   draw_hor_line([start_point.first, end_point.first], start_point.last, grid)
                 end
        end
      end
      grid[0] ||= []
      grid[0][500] = 'X'
      grid = fill_grid(grid)
      cleanup_grid(grid)
    end

    def cleanup_grid(grid)
      grid = grid.transpose[1..-1].transpose while grid&.transpose&.first&.uniq == ['.']
      grid
    end

    def fill_grid(grid)
      max = grid.compact.map(&:length).max - 1
      grid.map! do |row|
        row ||= []
        row[max] ||= nil
        row.map { |cell| cell.nil? ? '.' : cell }
      end
    end

    def draw_hor_line(x_coords, y_coord, grid)
      grid[y_coord] ||= []
      start_x = x_coords.min
      end_x = x_coords.max
      (start_x..end_x).each { |x| grid[y_coord][x] = '#' }
      grid
    end

    def draw_vert_line(x_coord, y_coords, grid)
      start_y = y_coords.min
      end_y = y_coords.max
      (start_y..end_y).each do |y|
        grid[y] ||= []
        grid[y][x_coord] = '#'
      end
      grid
    end
  end
end

cave = Cave.new(data)

cave.let_loose

!pp cave.sand_grains
