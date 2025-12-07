# frozen_string_literal: true

file = File.open('data_files/2023/examples/4_example', 'r')
# file = File.open('data_files/2023/data/4_data', 'r')
data = file.readlines.map(&:chomp)
file.close

# :nodoc:
class Game
  attr_reader :mappers, :seeds

  DESTINATION_CATEGORY = :location
  START_CATEGORY = :seed

  def initialize(seeds, mappers)
    @seeds = seeds
    @mappers = mappers
  end

  # Calculates the final location values for the given seeds
  def locations
    seeds.to_h do |seed|
      value = seed
      start_cat = START_CATEGORY
      loop do
        mapper = source_mapper_for(start_cat)
        value = mapper.destination_value(value)
        start_cat = mapper.destination_category
        break [seed, value] if start_cat == DESTINATION_CATEGORY
      end
    end
  end

  # @return [Hash<Source => Destination>]
  def source_to_destination
    map = destination_mapper_for(DESTINATION_CATEGORY)
    map.smallest_end_range.to_a.to_h do |dest|
      end_cat = DESTINATION_CATEGORY
      value = dest
      loop do
        mapper = destination_mapper_for(end_cat)
        value = mapper.source_value(value)
        end_cat = mapper.source_category
        break [value, dest] if end_cat == START_CATEGORY
      end
    end
  end

  # :nodoc:
  def source_mapper_for(category)
    mappers.find { |map| map.source_category == category }
  end

  # :nodoc:
  def destination_mapper_for(category)
    mappers.find { |map| map.destination_category == category }
  end

  # Answer to PT 1
  def smallest_location
    locations.values.min
  end

  # :nodoc:
  def smallest_location2
    seed_ranges = seeds.each_slice(2).to_a.map do |start, range|
      (start...(start + range))
    end
    start_mapping = seed_ranges.to_h { |seed_range| [seed_range, 0] }
    some_method(start_mapping, :seed)
  end

  # :nodoc:
  def some_method(mapping, source_destination)
    mapper = source_mapper_for(source_destination)
    !pp mapping
    return mapping if mapper.nil?

    new_mapper = mapping.map do |range, difference|
      mapper.ranges_mapping(range, difference)
    end.compact.inject({}, :merge)
    some_method(new_mapper, mapper.destination_category)
  end

  # :nodoc:
  def smallest_location2_dump
    hash_values = source_to_destination
    hash_values.reject! { |k, _v| k.negative? }
    minimal_mapped_sources = hash_values.keys
    smallest_location = hash_values.values.max
    seeds.each_slice(2).to_a.each do |start, range|
      overlap = (start...(start + range)).to_a & minimal_mapped_sources
      locations = overlap.map { |source| hash_values[source] }
      next if locations.compact.empty? || smallest_location < locations.min

      smallest_location = locations.min
      hash_values.reject! { |_k,v| v < smallest_location }

      minimal_mapped_sources = hash_values.keys
    end
    smallest_location
  end
end

# :nodoc:
class Map
  attr_reader :source_category,
              :destination_category,
              :ranges

  def initialize(source, target, ranges)
    @source_category = source
    @destination_category = target
    @ranges = ranges
  end

  # @return [Integer]
  def destination_value(source)
    range = ranges.find { |range| range.include?(source) }
    range ? range.destination_value(source) : source
  end

  # @return [Integer]
  def source_value(destination)
    range = ranges.find { |range| range.source_ranges.include?(destination) }
    range ? range.source_value(destination) : destination
  end

  def ranges_mapping(new_range, difference)
    temp_ranges = ranges.reject do |range|
      range.range.end < new_range.begin || range.range.begin > new_range.end
    end
    
    return { new_range => difference } if temp_ranges.empty?
    
    new_mapping = temp_ranges.to_h do |temp_range|
      [temp_range.range, temp_range.difference + difference]
    end
    temp_ranges.each_cons(2) do |first, second|
      new_mapping[(first.range.last...second.range.first)] = 0 if first.range.last < second.range.first
    end
    
    new_mapping[(new_range.begin...temp_ranges[0].range.begin)] = 0
    new_mapping[(temp_ranges[-1].range.end...new_range.end)] = 0
    new_mapping.select! { |k, _v| k.size > 0 } #clean-up
  end

end

# :nodoc:
class MapRange
  attr_reader :destination_range_start,
              :source_range_start,
              :range_length

  # :nodoc:
  def initialize(dest_range, source_range, length)
    @destination_range_start = dest_range
    @source_range_start = source_range
    @range_length = length
  end

  # @return [Integer] What gets added
  def difference
    destination_range_start - source_range_start
  end

  # @return [Range]
  def range
    (source_range_start...(source_range_start + range_length))
  end

  # @return [Boolean] if value is included in this mapping
  def include?(value)
    range.include?(value)
  end

  # @return [Integer]
  # (50, 98, 2) + 98 -> 50
  # (52, 50, 48) + 51 -> 53
  def destination_value(source)
    source - source_range_start + destination_range_start
  end

  # @return [Integer]
  # (50, 98, 2) + 50 -> 98
  # (52, 50, 48) + 53 -> 51
  def source_value(destination)
    destination - destination_range_start + source_range_start
  end

  # @return [<Integer>]
  def source_ranges
    (destination_range_start...(destination_range_start + range_length))
  end
end

seeds = data.shift.gsub('seeds: ', '').split(' ').map(&:to_i)
mappers = data.chunk { |row| row != '' || nil }
              .map(&:last)
              .map do |map_info|
  source, destination = map_info[0].split(' ')[0].split('-to-').map(&:to_sym)
  ranges = map_info[1..].map do |map_range_info|
    MapRange.new(*map_range_info.split(' ').map(&:to_i))
  end
  Map.new(source, destination, ranges)
end

game = Game.new(seeds, mappers)

!pp game.smallest_location
!pp game.smallest_location2