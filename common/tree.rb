# class for Tree
class Tree
  attr_accessor :value, :nodes, :parent, :layer

  def initialize(value, parent: nil)
    @value = value
    @nodes = []
    @parent = parent
    @layer = parent ? parent.layer + 1 : 0
  end

  def insert(node)
    @nodes << node
  end

  # Search for a value in the tree
  def search(value)
    search_recursive(@root, value)
  end

  def traverse(depth)
    return value if depth.zero?

    nodes.flat_map do |node|
      node.traverse(depth - 1)
    end
  end

  def count_traverse(depth)
    collection = nodes.to_h { |node| [node, 1] }
    end_collection = smart_traverse_with_collection(depth, collection)
    end_collection.sum(&:last)
  end

  def smart_traverse_with_collection(depth, collection)
    until depth.zero? do
      one_down = {}
      collection.each do |current_node, count|
        current_node.nodes.each do |new_node|
          one_down[new_node] ||= 0
          one_down[new_node] += count
        end
      end
      depth = depth - 1
      collection = one_down
    end
    collection
  end

  def sample_traverse(depth)
    return value if depth.zero?

    node.sample.traverse(depth - 1)
  end

  def to_s
    value
  end

  alias_method :inspect, :to_s

  private

  def search_recursive(node, value)
    return nil if node.nil?
    return node if node.value == value

    nodes.select do |node|
      search_recursive(node, value)
    end.flatten
  end
end