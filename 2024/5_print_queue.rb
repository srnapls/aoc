# frozen_string_literal: true

require_relative '../generic'
require_relative '../common/matrix'

FILE_EXAMPLE = '2024/5/example'
FILE = '2024/5/assignment'
USE_FILE = FILE

# A class representing SafetyManual
class SafetyManual
  attr_reader :page
  attr_accessor :ordering

  def initialize(page, ordering)
    @page = page
    @ordering = ordering
  end

  def <=>(other)
    if ordering.include?(other.page)
      - 1 # a < b
    elsif other.ordering.include?(page)
      1 # a > b
    else
      0 # a == b
    end
  end

  def to_s
    page.to_s
  end

  alias inspect to_s
end

def data
  rules, updates = read_file(USE_FILE).slice_before { |elt| elt == '' }.to_a
  rules.map! { |rule| rule.split('|') }
  updates = updates.drop(1)
  updates.map! { |update| update.split(',') }
  [rules, updates]
end

def manuals
  @manuals ||= begin
    rules = data.first
    grouping = rules.group_by(&:first).transform_values { |comb| comb.map(&:last) }
    grouping.to_h { |k, v| [k, SafetyManual.new(k, v)] }
  end
end

def valid_update?(update)
  update.sort == update
end

def middle_page_number(update)
  update[update.size / 2]
end

def updates
  data.last.map do |update_line|
    update_line.map { |page_number| manuals[page_number] || SafetyManual.new(page_number, []) }
  end
end

def main_part_one
  updates.select { |update| valid_update?(update) }
         .map { |update| middle_page_number(update) }
         .map(&:page)
         .map(&:to_i)
         .sum
end

def main_part_two
  updates.reject { |update| valid_update?(update) }
         .map(&:sort)
         .map { |update| middle_page_number(update) }
         .map(&:page)
         .map(&:to_i)
         .sum
end


puts main_part_two
