# frozen_string_literal: true

require_relative '../common/graph'

file = File.open('2022/data_files/proboscidea_volcanium', 'r')
data = file.readlines.map(&:chomp).map{|line| line.split(' ')}
file.close


class Valve
  attr_reader :name, :rate
  def initialize(name, rate)
    @name = name
    @rate = rate
  end

  def to_s
    "Valve #{name} has rate=#{rate}"
  end
end

class SystemParser
  class << self
    def parse_lines(lines)
      nodes = []
      routes = {}
      lines.each do |line|
        node, route = parse_line(line)
        nodes << node
        routes[node] = route
      end
      nodes.each do |node|
        routes[node].map! do |other_node|
          nodes.find{|n| n.name == other_node}
        end
      end
      [nodes, routes]
    end

    def parse_line(line)
      name = line[1]
      rate = line[4].split('=').last[0..-2].to_i
      leads_to = line[9..-1]
      [Valve.new(name, rate), leads_to]
    end
  end
end

class System < Graph

end

nodes, paths = SystemParser.parse_lines(data)

system = System.new(nodes, paths: paths)
!pp system