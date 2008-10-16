require 'file_formats'
require 'nucleotide'
class Sequence 
  include Enumerable
  
  def initialize(*args)
    if args.length == 1
      @name = ""
      if args[0].class == Array 
        @sequence = args[0]
      elsif args[0].class == String
        @sequence = args[0].split ''
      else
        throw Exception.new "Sequence should be initialized from a string or array if only 1 argument is used"
      end
    elsif args.length == 2
      filename = args[0]
      filetype = args[1]
      #assuming filetype == 'old' for time being
      @name, @sequence = FileFormats.old_to_name_and_string(filename)
      @sequence = @sequence.split
    end
  end

  def reverse_complement
    result = []
    @sequence.reverse.each do |nucleotide|
      result << nucleotide.complement
    end
    return result
  end
  
  def to_s
    @sequence.join
  end
  
  def n_mers(n)
    n_mers = {}
    0.upto(@sequence.length - n) do |i|
      n_mers[@sequence[i,n]] ||= []
      n_mers[@sequence[i,n]] << i
    end
    return n_mers
  end
end
