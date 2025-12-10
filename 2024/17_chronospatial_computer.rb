# frozen_string_literal: true

require_relative '../generic'
require_relative '../common/point'
require_relative '../common/grid'
require 'set'

FILE_EXAMPLE = '2024/17/example'
FILE = '2024/17/assignment'
USE_FILE = FILE_EXAMPLE

# A class representing the warehouse
class Computer
  attr_accessor :register_a, :register_b, :register_c
  attr_reader :program

  def initialize(a_value, program)
    @register_b = 0
    @register_c = 0
    @register_a = a_value
    @program = program
  end

  def run_program
    @program.each_cons(2) do |opcode, operand|
      case opcode
      when 0 then adv(operand)
      when 1 then bxl(operand)
      when 2 then bst(operand)
      when 3 then jnz(operand)
      when 4 then bxc(operand)
      when 5 then out(operand)
      when 6 then bdv(operand)
      when 7 then cdv(operand)
      end
    end
  end

  def combo_operand(number)
    case number
    when 0..3 then number
    when 4 then @register_a
    when 5 then @register_b
    when 6 then @register_c
    end
  end

  def literal_operand(number)
    number
  end

  def adv(number)
    register_a / (2^combo_operand(number))
  end

  def bxl(number)
    register_b.to_s(2) ^ literal_operand(number).to_s(2)
  end

  def jnz(number)
    return if register_a.zero?

    
  end
end

def data
  values = {}
  lines = read_file(USE_FILE)
  value_a = lines.first.split(':').last.to_i
  program = lines.last.split(':').last.split(',').map(&:to_i)
  Computer.new(value_a, program)
end

comp = data
!pp comp
