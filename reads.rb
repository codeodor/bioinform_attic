# A read is a collection of n mers.
class Reads
  include Enumerable
  
  def initialize(*args)
    if args.length == 2
      # will eventually handle array of sequences of size @n, or array of strings, or array of arrays, or sequence.n_mers(@n)
      @n_mers = args[0]  
      @n = args[1] 
    elsif args.length == 3
      filename_containing_reads = args[0]
      filetype = args[1]
      @n = args[2]
      #todo: construct n_mers from file
    else
      throw Exception.new 'Invalid arguments to construct a collection of reads'
    end
  end
  
  def to_s
    require 'pp'
    PP.pp @n_mers
  end
  
  def map_to(sequence)
    sequence_nmer_positions = 
  end
  
  def discard_if_present_in(sequence)
    
  end
end