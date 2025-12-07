# frozen_string_literal: true

file = File.open('data_files/monkey_in_the_middle', 'r')
data = file.readlines.map(&:chomp)
file.close

# a monkey class
class Monkey
  attr_accessor :queue, :operation, :test_div, :next_monkey, :nr_of_items, :relief_lvl

  def initialize(queue, operation, test_div, next_monkey)
    @queue = queue
    @operation = operation
    @test_div = test_div
    @next_monkey = next_monkey
    @nr_of_items = 0
    @relief_lvl = nil
  end

  # @return [<Int, Int>] <Next monkey, item>
  def turn
    return nil if queue.empty?

    old = queue.shift
    worry_lvl = eval(operation)
    worry_lvl = relief(worry_lvl)

    @nr_of_items += 1
    [next_monkey[test(worry_lvl)], worry_lvl]
  end

  def relief(worry_level)
    worry_level % @relief_lvl
  end

  def test(worry_lvl)
    (worry_lvl % test_div).zero?
  end

  def add_item(item)
    queue << item
  end

  def add_relief(relief)
    @relief_lvl = relief
  end

  def to_s
    queue.map(&:to_s).join(', ')
  end
end

# a parser for a monkey
class MonkeyParser
  def self.parse(input)
    items = input[1].split(':').last.split(', ').map(&:to_i)
    operation = input[2].split(':').last
    test_div = input[3].split(' by ').last.to_i
    true_val = input[4].split(' monkey ').last.to_i
    false_val = input[5].split(' monkey ').last.to_i
    eval = { true => true_val, false => false_val }
    Monkey.new(items, operation, test_div, eval)
  end
end

# the forst/ game handler
class Forest
  attr_accessor :monkeys

  def initialize
    @monkeys = []
  end

  def add_monkey(monkey)
    @monkeys << monkey
  end

  def round
    monkeys.each do |monkey|
      loop do
        info = monkey.turn
        break if info.nil?

        monkeys[info.first].add_item(info.last)
      end
    end
  end

  def perform_nr_of_rounds(number)
    new_relief
    number.times { round }
  end

  def to_s
    monkeys.map.with_index do |monkey, index|
      "Monkey #{index}: #{monkey}"
    end.join("\n")
  end

  def inspection_string
    inspection.map.with_index do |nr_of_items, index|
      "Monkey #{index} inspected items #{nr_of_items} times"
    end.join("\n")
  end
  
  def inspection
    monkeys.map {|monkey| monkey.nr_of_items}
  end

  def monkey_business
    inspection.sort.last(2).inject(1, :*)
  end

  def new_relief
    relief = monkeys.map(&:test_div).inject(1, :*)
    monkeys.each {|monkey| monkey.add_relief(relief)}
  end
end

monkey = []
forest = Forest.new

loop do
  line = data.shift
  monkey << line unless line.empty?
  if monkey.size == 6
    forest.add_monkey(MonkeyParser.parse(monkey))
    monkey = []
  end
  break if data.empty?
end

forest.perform_nr_of_rounds(10_000)
puts forest.inspection_string
puts forest.monkey_business

