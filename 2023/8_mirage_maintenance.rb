# frozen_string_literal: true

# file = File.open('data_files/2023/examples/8_example', 'r')
file = File.open('data_files/2023/data/8_data', 'r')
data = file.readlines.map(&:chomp)
file.close

# :nodoc:
class History
  attr_reader :values
  attr_accessor :all_rows

  def initialize(values)
    @values = values
    @all_rows = [values]
  end

  def prediction
    gather_rows
    all_rows.map(&:last).sum
  end

  def next_row(row_values)
    new_row = []
    row_values.each_cons(2) { |first, second| new_row << second - first }
    new_row
  end

  def gather_rows
    current_row = values
    loop do
      current_row = next_row(current_row)
      all_rows << current_row
      break if current_row.uniq.length == 1 && current_row.sample.zero?
    end
  end

  def extrapolation
    gather_rows
    all_rows.map(&:first).reverse.inject(0) do |current_val, val|
      val - current_val
    end
  end
end

histories = data.map do |row|
  History.new(row.split(' ').map(&:to_i))
end

!pp histories.map(&:extrapolation).sum
