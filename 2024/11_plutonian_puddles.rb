# frozen_string_literal: true

require_relative '../generic'
require_relative '../common/tree'
require 'set'

FILE_EXAMPLE = '2024/11/example'
FILE = '2024/11/assignment'
USE_FILE = FILE

# A class representing the topographic hiking map
class Puddle
  attr_accessor :stones
  attr_accessor :growth_generation
  attr_accessor :values_found

  NR_OF_BLINKS = 75

  def initialize(input)
    @stones = input
    @values_found = {}
    @growth_generation = Tree.new(nil)
    @stones.each do |stone|
      new_tree = Tree.new(stone, parent: @growth_generation)
      @growth_generation.insert(new_tree)
      @values_found[stone] = new_tree
    end
  end

  def investigate
    nodes = @growth_generation.nodes
    NR_OF_BLINKS.times do |layer|
      nodes = stretch_one_layer(nodes)
    end
  end

  def stretch_one_layer(nodes)
    nodes.flat_map do |node|
      next if node.nil?

      new_stones = blink(node.value)
      new_stones.map do |new_stone|
        if @values_found.key?(new_stone)
          existing_node = @values_found[new_stone]
          node.insert(existing_node)
          nil
        else
          existing_node.nil?
          new_node = Tree.new(new_stone, parent: node)
          node.insert(new_node)
          @values_found[new_stone] = new_node
          new_node
        end
      end
    end
  end

  def blink(stone)
    if stone.zero?
      [1]
    elsif stone.to_s.length.even?
      str = stone.to_s
      [str[0..(str.length / 2) - 1].to_i, str[(str.length / 2)..].to_i]
    else
      [stone * 2024]
    end
  end

  def count_the_stones
    investigate
    @growth_generation.count_traverse(NR_OF_BLINKS)
  end
end

def data
  input = read_file(USE_FILE).map.first.split(' ').map(&:to_i)
  Puddle.new(input)
end

puddle = data
puts puddle.count_the_stones





