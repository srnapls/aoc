# frozen_string_literal: true

file = File.open('data_files/no_space_left_on_device', 'r')
data = file.readlines.map(&:chomp)
file.close

# directories
class Directory
  attr_accessor :parent, :name, :files, :directories

  def initialize(parent:, name:)
    @parent = parent
    @name = name
    @files = []
    @directories = []
  end

  def size
    @files.map(&:size).sum + @directories.map(&:size).sum
  end

  def map_sizes
    sizes = { self => size }
    @directories.each do |dir|
      temp = dir.map_sizes
      sizes.merge!(temp)
    end
    sizes
  end

  def add_dir(directory)
    @directories << directory if @directories.none? {|dir| dir.name == directory.name}
  end

  def add_file(new_file)
    @files << new_file if @files.none? {|file| file.name == new_file.name}
  end

  def cd(dir_name)
    @directories.find { |dir| dir.name == dir_name }
  end

  def add_files!(files)
    files.each do |file|
      info = file.split
      if info.first == 'dir'
        new_dir = Directory.new(name: info[1], parent: self)
        add_dir(new_dir)
      else
        new_file = File.new(name: info[1], size: info[0].to_i, parent: self)
        add_file(new_file)
      end
    end
  end
end

# files
class File
  attr_accessor :parent, :name, :size

  def initialize(parent:, name:, size:)
    @parent = parent
    @name = name
    @size = size
  end
end

instructions = []
data.chunk { |line| line.split(' ').first == '$' }.each do |mark, lines|
  mark ? instructions.append(*lines) : instructions << lines
end

root = Directory.new(name: 'root', parent: nil)
home = Directory.new(name: '/', parent: root)
root.add_dir(home)
current_directory = root

instructions.each do |instruction|
  case instruction
  when Array
    current_directory.add_files!(instruction)
  when '$ ls'
    next
  when '$ cd ..'
    current_directory = current_directory.parent
  else
    dir_name = instruction.split(' ').last
    current_directory = current_directory.cd(dir_name)
  end
end

root_sizes = root.cd('/').map_sizes
root_sizes.filter{ |_, v| v <= 100_000 }.map(&:last).sum

available_storage = 70_000_000 - root.cd('/').size
needed_storage = 30_000_000 - available_storage

!pp root_sizes.filter{ |_, v| v >= needed_storage}.map(&:last).min
