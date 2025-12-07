# frozen_string_literal: true

require 'set'

# Class representing a mathematical graph
class Graph
  attr_accessor :nodes, :vertices, :weight, :paths

  def initialize(nodes, vertices: nil, paths: nil)
    nodes = Set.new(nodes)
    @paths = paths || set_paths(vertices)
  end

  private

  def set_paths(vertices)
    vertices.each do |pair|
      @paths[pair.first] ||= []
      @paths[pair.first] << pair.last
    end
  end
end
