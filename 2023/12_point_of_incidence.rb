# frozen_string_literal: true

require_relative '../common/point'
require_relative '../common/grid'
require 'set'

# file = File.open('data_files/2023/examples/12_example', 'r')
# file = File.open('data_files/2023/examples/12_example2', 'r')
file = File.open('data_files/2023/data/12_data', 'r')
data = file.readlines.map(&:chomp).slice_when { |_, j| j.empty? }
file.close

# :nodoc:
class MirrorField
  attr_accessor :grid, :horizontal_mirror, :vertical_mirror

  def initialize(grid, part_one: false)
    @grid = grid
    if part_one
      @horizontal_mirror = find_horizontal_mirror
      @vertical_mirror = find_vertical_mirror
    else
      @horizontal_mirror = find_smudge_mirror_pos(grid)
      @vertical_mirror = find_smudge_mirror_pos(grid.transpose)
    end
  end

  def find_horizontal_mirror
    return unless grid.uniq.size < grid.size

    find_mirror_pos(grid)
  end

  def find_vertical_mirror
    return unless grid.transpose.uniq.size < grid[0].size

    find_mirror_pos(grid.transpose)
  end

  def find_mirror_pos(situation)
    possible_slices = situation.slice_when { |i, j| i == j }.to_a
    (0..possible_slices.size - 1).each do |cut_index|
      front = possible_slices[0..cut_index].flatten(1)
      back = possible_slices[cut_index + 1..].flatten(1)

      next if front.empty? || back.empty?

      return front.length if mirror?(front, back)
    end
    nil
  end

  def find_smudge_mirror_pos(situation)
    possible_slices = situation.slice_when do |i, j|
      i == j || differences(i, j) == 1
    end.to_a
    (0..possible_slices.size - 1).each do |cut_index|
      front = possible_slices[0..cut_index].flatten(1)
      back = possible_slices[cut_index + 1..].flatten(1)

      next if front.empty? || back.empty?

      return front.length if smudge_mirror?(front, back)
    end
    nil
  end

  def smudge_mirror?(front, back)
    smudge_used = false
    front.reverse.zip(back).all? do |front_lane, back_lane|
      if front_lane.nil? || back_lane.nil? || front_lane == back_lane
        true
      else
        differences = differences(front_lane, back_lane)
        if differences == 1 && !smudge_used
          smudge_used = true
          true
        else
          false
        end
      end
    end && smudge_used
  end

  def differences(front, back)
    count = 0
    front.zip(back).each do |i, j|
      count += 1 if i != j
    end
    count
  end

  def mirror?(front, back)
    front.reverse.zip(back).all? do |front_lane, back_lane|
      return true if front_lane.nil? || back_lane.nil?

      front_lane == back_lane
    end
  end

  def notes
    (horizontal_mirror || 0) * 100 + (vertical_mirror || 0)
  end
end

mirror_fields = data.map do |mirror_grid|
  MirrorField.new(mirror_grid.reject(&:empty?)
                             .map { |row| row.split('') })
end

!pp mirror_fields.map(&:notes).sum
