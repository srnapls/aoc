# frozen_string_literal: true

require 'set'

file = File.open('data_files/cathode_ray_tube', 'r')
data = file.readlines.map(&:chomp).map { |e| e.split(' ') }
file.close

# raytube
class RayTube
  attr_accessor :x_value, :cycle, :signal_strength, :crt_screen, :sprite, :total_screen

  def initialize
    @x_value = 1
    @cycle = 1
    @signal_strength = {}
    Array.new(6) { |i| 20 + i * 40 }.each { |int| @signal_strength[int] = nil }
    @sprite = []
    @crt_screen = []
    @total_screen = []
  end

  def to_s
    ["Current X: #{@x_value}",
     "Current cycle: #{@cycle}",
     'Current sprite:',
     @sprite.join(''),
     'Current CRT screen:',
     @crt_screen.join('')].join("\n")
  end

  def update_signal_strength
    if @signal_strength.keys.include?(@cycle)
      @signal_strength[@cycle] = @cycle * @x_value
    end
  end

  def update_screen
    @crt_screen << (positioned? ? '#' : '.')
    if @crt_screen.size == 40
      @total_screen << @crt_screen
      @crt_screen = []
      update_sprite
    end
  end

  def positioned?
    @sprite[@crt_screen.size] == '#'
  end

  def noop
    update_sprite
    update_screen
    @cycle += 1
    update_signal_strength
  end

  def update_sprite
    middle = @x_value % 40
    @sprite = Array.new(40) { '.' }
    @sprite[middle - 1] = '#' if middle >= 1
    @sprite[middle] = '#'
    @sprite[middle + 1] = '#' if middle < 39
  end

  def addx(number)
    noop

    update_sprite
    update_screen
    @cycle += 1
    @x_value += number.to_i
    update_signal_strength
  end
end

ray_tube = RayTube.new
data.each do |inst|
  ray_tube.send(*inst)
end

puts ray_tube.signal_strength
puts ray_tube.total_screen.map {|screen| screen.join('')}.join("\n")
#
# puts ray_tube
#
