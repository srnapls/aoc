# frozen_string_literal: true

require_relative '../generic'
require_relative '../common/grid'
require_relative '../common/point'
require 'set'

FILE_EXAMPLE = '2024/9/example'
FILE_EXAMPLE0 = '2024/9/example0'
FILE = '2024/9/assignment'
USE_FILE = FILE_EXAMPLE

# A class representing the Guard
class Disk
  attr_accessor :map

  def initialize(input)
    @map = []
    number_ids = 0
    input.each_slice(2) do |files, free_space|
      files.times { @map << number_ids }
      free_space&.times { @map << nil }

      number_ids += 1
    end
  end

  def fill_spaces1
    @map.map! do |space|
      if space.nil?
        number = @map.pop
        @map.pop while @map[-1].nil?
        number
      else
        space
      end
    end
  end

  def fill_spaces2
    new_array = []
    blocks = @map.slice_when { |i, j| i != j }.to_a
    puts blocks.inspect
    while blocks.length.positive?
      block_to_move = blocks.pop
      location = blocks.find_index { |block| block.first.nil? && block_to_move.size <= block.size }
      if location.nil?
        new_array << block_to_move
      else
        free_space_block = Array.new(blocks[location].size - block_to_move.size) { nil }
        blocks[location] = block_to_move
        blocks.insert(location + 1, free_space_block) if free_space_block.length.positive?
        new_array << Array.new(block_to_move.size) { nil }
      end

      new_array << blocks.pop if blocks.last&.include?(nil)
    end
    @map = new_array.reverse.flatten
  end

  def checksum
    fill_spaces2
    @map.each_with_index.sum do |space, i|
      (space || 0) * i
    end
  end
end

def data
  input = read_file(USE_FILE).first.chars.map(&:to_i)
  Disk.new(input)
end

grid = data
puts grid.checksum




