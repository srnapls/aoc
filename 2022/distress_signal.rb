# frozen_string_literal: true

file = File.open('data_files/distress_signal', 'r')
data = file.readlines.map(&:chomp).compact.map { |l| l == '' ? nil : eval(l) }.compact
file.close

# packets
class Packet
  attr_accessor :message

  def initialize(message)
    @message = message
  end

  def <=>(other)
    right_order?(@message, other.message).last ? -1 : 1
  end

  def right_order?(packet, other_packet)
    packet = packet.clone
    packet << nil while packet.size < other_packet.size

    packet.zip(other_packet).each do |l, r|
      if both_int?(l, r)
        (return [true, l < r]) if l != r
      elsif both_array?(l, r)
        evaluation = right_order?(l, r)
        return evaluation if evaluation.first
      elsif (l.is_a? Integer) && (r.is_a? Array)
        evaluation = right_order?([l], r)
        return evaluation if evaluation.first
      elsif (l.is_a? Array) && (r.is_a? Integer)
        evaluation = right_order?(l, [r])
        return evaluation if evaluation.first
      else
        return [true, l.nil?]
      end
    end
    [false, true]
  end

  def both_int?(l, r)
    (l.is_a? Integer) && (r.is_a? Integer)
  end

  def both_array?(l, r)
    (l.is_a? Array) && (r.is_a? Array)
  end
end



# values = data.each_slice(2).map.with_index do |slice, index|
#   actual_index = index + 1
#   left = slice[0]
#   right = slice[1]
#   right_order?(left, right).last ? actual_index : nil
# end.compact

packets = data.map { |m| Packet.new(m) }
div_2 = Packet.new([[2]])
div_6 = Packet.new([[6]])
packets << div_2
packets << div_6

!pp packets.size
sorted_packets = packets.sort
div_2_index = sorted_packets.find_index(div_2)
div_6_index = sorted_packets.find_index(div_6)

!pp sorted_packets
!pp (div_2_index + 1)*(div_6_index + 1)