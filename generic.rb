# frozen_string_literal: true

# Read the file from the path
def read_file(path)
  file = File.open("data_files/#{path}", "r")
  data = file.readlines.map(&:chomp)
  file.close
  data
end

def example_file = "#{file_path}/example"

def file_path = $0.split('_').first

def assignment_file = "#{file_path}/assignment"
