file = File.open('data_files/camp_cleanup', 'r')
data = file.readlines.map(&:chomp)
file.close

def parse_entry(entry)
  entry.split(',').map{ |e| to_range(e.split('-').map(&:to_i)) }
end

def to_range(arr)
  (arr[0]..arr[1])
end

def each_other_ranges?(first, second)
  first.cover?(second) || second.cover?(first)
end

def includes_entry?(entry)
  each_other_ranges?(*parse_entry(entry))
end

def overlap?(first, second)
  (first.to_a & second.to_a).any?
end

def overlap_entry?(entry)
  overlap?(*parse_entry(entry))
end

puts data.count {|entry| includes_entry?(entry)}

puts data.count {|entry| overlap_entry?(entry)}
