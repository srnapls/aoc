# frozen_string_literal: true

file = File.open('data_files/supply_stacks', 'r')
data = file.readlines.map(&:chomp)
file.close

REGEXP = /\A\w+ (?<number>\d+) \w+ (?<orig_stack>\d+) \w+ (?<new_stack>\d+)\z/.freeze

def parse_setup(setup)
  stacks = []
  setup.each do |line|
    line.split('').each_slice(4).with_index do |segment, index|
      letter = segment[1]
      next if letter.strip.empty?

      (stacks[index] ||= []) << letter
    end
  end
  stacks.map(&:reverse)
end

start_instructions = data.find_index { |line| line.match(REGEXP) }

stacks = parse_setup(data[0..(start_instructions - 3)])


instructions = data[start_instructions..-1]
instructions.each.with_index do |instruction|
  match_instruction = instruction.match(REGEXP)
  number = match_instruction[:number].to_i
  orig_stack = match_instruction[:orig_stack].to_i - 1
  new_stack = match_instruction[:new_stack].to_i - 1
  blocks = stacks[orig_stack].pop(number)
  # stacks[new_stack].push(*blocks.reverse)
  stacks[new_stack].push(*blocks)
end

puts stacks.map(&:last).join('')
