# frozen_string_literal: true

file = File.open('data_files/treetop_tree_house', 'r')
data = file.readlines.map(&:chomp).map{ |e| e.split('') }
file.close

# trees
class Tree
  attr_accessor :length, :neighbours

  def initialize(length:)
    @length = length
    @neighbours = { 'north' => nil, 'east' => nil, 'south' => nil, 'west' => nil }
  end

  def add_neighbour(direction, tree)
    return unless @neighbours[direction].nil?

    @neighbours[direction] = tree
    tree.add_neighbour(reverse(direction), self)
  end

  def reverse(dir)
    index = @neighbours.keys.index(dir)
    @neighbours.keys[index - 2]
  end

  def neighbours_in_dir(direction)
    neighbour = neighbours[direction]
    return [] if neighbour.nil?

    all_neighbours = neighbour.neighbours_in_dir(direction)
    all_neighbours.nil? ? [neighbour] : [neighbour] + all_neighbours
  end

  def visible_from_direction?(dir)
    neighbours = neighbours_in_dir(dir)
    neighbours.empty? ? true : neighbours.map(&:length).max < length
  end

  def visible?
    @neighbours.keys.any? { |dir| visible_from_direction?(dir) }
  end

  def scenic_dir_score(dir)
    neighbours = neighbours_in_dir(dir)
    return 0 if neighbours.empty?

    pos = neighbours.find_index { |tree| tree.length >= length}
    pos.nil? ? neighbours.size : pos + 1
  end

  def scenic_score
    @neighbours.keys.map{|dir| scenic_dir_score(dir)}.inject(1, :*)
  end

end

trees = data.map { |rows| rows.map { |size| Tree.new(length: size.to_i) } }

trees.each.with_index do |tree_row, row|
  tree_row.each.with_index do |tree, column|
    tree.add_neighbour('north', trees[row - 1][column]) if (row - 1).positive?
    tree.add_neighbour('east', trees[row][column + 1]) if column + 1 < tree_row.size
    tree.add_neighbour('south', trees[row + 1][column]) if row + 1 < trees.size
    tree.add_neighbour('west', trees[row][column - 1]) if (column - 1).positive?
  end
end

puts trees.map{|row| row.count {|tree| tree.visible? }}.sum
puts trees.map{|row| row.map {|tree| tree.scenic_score }.max}.max
