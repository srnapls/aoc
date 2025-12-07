# frozen_string_literal: true

require 'set'

file = File.open('data_files/beacon_exclusive_zone', 'r')
data = file.readlines.map(&:chomp)
file.close

data.map! {|line0| line0.split(':').map{|line| line.split(',').map{ |line2| line2.split('=').last.to_i}}}

class Range
  def <=>(other)
    self.begin <=> other.begin
  end

  def union(other)
    return nil if !overlap?(other)

    [self.begin, other.begin].min..[self.max, other.max].max
  end

  def overlap?(other)
    self.include?(other.begin) || other.include?(self.begin)
  end

end

# the zone
class Zone
  attr_accessor :map, :max_size, :beacons, :sensors, :beacons_x_on_height

  def initialize(input, height)
    @map = Set.new
    @sensors = []
    @max_size = height
    @beacons_x_on_height = {}
    read_map(input)
  end

  def read_map(input)
    input.each do |line|
      !pp line
      add_sensor_and_beacon(*line)
    end
  end

  def find_tuning_frequency
    tuning_frequency(*find_distress_beacon)
  end

  def find_distress_beacon
    (0..@max_size).each do |height|
      ranges = @beacons_x_on_height[height].to_a.sort
      current_range = (0..0)
      ranges.each do |range|
        if !current_range.union(range).nil?
          current_range = current_range.union(range)
        elsif current_range.end + 1 >= range.begin
          current_range = (current_range.begin..range.end)
        else
          return [current_range.end + 1, height]
        end
      end
    end
  end

  def add_sensor_and_beacon(sensor, beacon)
    @sensors << sensor
    # @beacons_x_on_height << beacon.first if beacon.last == @height

    (0..@max_size).each do |height|
      add_ranges(sensor, manhattan_distance(sensor, beacon), height)
    end
  end

  def height_included?(start_point, distance, height)
    height_1 = start_point.last + distance
    height_2 = start_point.last - distance
    heights = [height_1, height_2].sort
    (heights.first..heights.last).include?(height)
  end

  def add_ranges(start_point, distance, height)
    return unless height_included?(start_point, distance, height)

    left_point = add_dx(start_point, distance * -1)
    right_point = add_dx(start_point, distance)
    if start_point.last <= height
      x_1 = left_point.first + (height - left_point.last)
      x_2 = right_point.first - (height - right_point.last)
    else
      x_1 = left_point.first + (left_point.last - height)
      x_2 = right_point.first - (left_point.last - height)
    end
    add_range(height, *[x_1,x_2].sort)
  end

  def add_range(height, start_x, end_x)
    @beacons_x_on_height[height] ||= Set.new
    @beacons_x_on_height[height] << ([start_x, 0].max..[end_x, 0].max)
  end

  def add_slots(start_point, distance)
    return unless height_included?(start_point, distance, @height)

    left_point = add_dx(start_point, distance * -1)
    right_point = add_dx(start_point, distance)
    if start_point.last <= @height
      x_1 = left_point.first + (@height - left_point.last)
      x_2 = right_point.first - (@height - right_point.last)
    else
      x_1 = left_point.first + (left_point.last - @height)
      x_2 = right_point.first - (left_point.last - @height)
    end
    add_in_range(*[x_1, x_2].sort)
  end

  def add_in_range(start_x, end_x)
    @map.merge((start_x..end_x).to_a)
  end

  def add_dx(point, div_x)
    [point.first + div_x, point.last]
  end

  def manhattan_distance(p1, p2)
    (p1.first - p2.first).abs + (p1.last - p2.last).abs
  end

  def tuning_frequency(x, y)
    4_000_000 * x + y
  end
end

# zone = Zone.new(data, 20)
# !pp zone.find_tuning_frequency
#
zone = Zone.new(data, 4_000_000)
!pp zone.find_tuning_frequency
# 5457710 is wrong lmao
# 4692643 is wrong

