# frozen_string_literal: true

require_relative '../generic'
require_relative '../common/matrix'
require_relative '../common/grid'
require 'set'

FILE_EXAMPLE = '2024/13/example'
FILE = '2024/13/assignment'
USE_FILE = FILE

# class
class Arcade
  attr_accessor :claw_contraptions

  def initialize(list)
    @claw_contraptions = list
  end

  def all_tokens
    claw_contraptions.sum(&:tokens)
  end
end

# Class
class ClawContraption
  attr_accessor :x_result, :y_result, :button_a_x, :button_a_y, :button_b_x, :button_b_y

  def initialize(results, button_a, button_b)
    @x_result, @y_result = results
    @button_a_x, @button_a_y = button_a
    @button_b_x, @button_b_y = button_b
  end

  def tokens
    if nr_of_a.zero? || nr_of_b.zero?
      0
    else
      3 * nr_of_a + nr_of_b
    end
  end

  def nr_of_a
    top = (y_result * button_b_x - x_result * button_b_y)
    bottom = (button_b_x * button_a_y - button_a_x * button_b_y)
    return top / bottom if (top % bottom).zero?

    0
  end

  def nr_of_b
    top = (y_result * button_a_x - x_result * button_a_y)
    bottom = (button_a_x * button_b_y - button_b_x * button_a_y)
    return top / bottom if (top % bottom).zero?

    0
  end
end

def data(add_digits: true)
  machines = []
  read_file(USE_FILE).slice_when { |i, _j| i == '' }.each do |block|
    results = block[2].split(',').map { |b| b.gsub(/\D/, '').to_i }
    button_a = block[0].split(',').map { |b| b.gsub(/\D/, '').to_i }
    button_b = block[1].split(',').map { |b| b.gsub(/\D/, '').to_i }
    results.map! { |d| 10_000_000_000_000 + d } if add_digits
    machine = ClawContraption.new(results, button_a, button_b)
    puts machine.inspect
    machines << machine
  end
  Arcade.new(machines)
end

puts data.all_tokens