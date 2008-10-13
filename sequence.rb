module Nucleotide
  def complement
    result = ""
    self.each do |nucleotide|
      result << 't' if nucleotide == 'a'
      result << 'a' if nucleotide == 't'
      result << 'c' if nucleotide == 'g'
      result << 'g' if nucleotide == 'c' 
    end
    return result
  end
end

class String 
  include Nucleotide
end

module Sequence
  def reverse_complement
    result = self.empty
    self.reverse.each do |nucleotide|
      result << nucleotide.complement
    end
    return result
  end
end

module Enumerable
  include Sequence
end

s = ['a','c','t','g']
#s = "actg"
puts s.reverse_complement.join