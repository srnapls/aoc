# frozen_string_literal: true

# Extends the class Range
class Range
  def intersection(other)
    return nil if (self.max < other.begin or other.max < self.begin)

    [self.begin, other.begin].max..[self.max, other.max].min
  end
  alias_method :&, :intersection

  def union(other)
    return nil if (self.max > other.begin || other.max > self.begin)

    [self.begin, other.begin].min..[self.max, other.max].max
  end

end

