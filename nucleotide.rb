module Nucleotide # these will eventually be numbers
  def complement
    result = ""
    self.each do |nucleotide|
      result << 'T' if nucleotide == 'a'
      result << 'A' if nucleotide == 't'
      result << 'C' if nucleotide == 'g'
      result << 'G' if nucleotide == 'c'
      
      result << 'T' if nucleotide == 'A'
      result << 'A' if nucleotide == 'T'
      result << 'C' if nucleotide == 'C'
      result << 'G' if nucleotide == 'G' 
    end
    return result
  end
end

class String 
  include Nucleotide
end