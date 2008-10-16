# A read is a collection of n mers.
class Reads
  include Enumerable
  
  def initialize(*args)
    if args.length == 2
      # will eventually handle array of sequences of size @n, or array of strings, or array of arrays, or sequence.n_mers(@n)
      # for now, it expects sequence.n_mers(n), which it currently converts from read->where to read->how_many
      temp_n_mers = args[0] 
      @n_mers = {}
      temp_n_mers.each_key do |key|
        @n_mers[key] = temp_n_mers[key].length
      end
         
      @n = args[1] #not loving the name.  But @length doesn't work either. 
    elsif args.length == 3
      throw Exception.new 'Not implemented yet...'
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
    throw Exception.new "Holy Guacamole! This method is yet to be implemented! Eh!?"
    sequence_nmer_positions = ""
  end
  
  def discard_if_present_in(sequence) #need one to discard if w/in certain # of mismatches
    result = {}
    sequence_n_mers = sequence.n_mers(@n) #this effectively turns them into Reads. Should it actually? 
    #what object should be in charge here?
    
    #iteration over the smaller one doesn't matter b/c we have to check all local 
    #ones no matter what (and sequence_n_mers has o(1) access anyway)
    @n_mers.each_key do |key|
      result[key] = @n_mers[key] if !sequence_n_mers[key]
      # next line is completed messed up, but have to do it until we accept hashes as input for constructor
      if !sequence_n_mers[key]
        # fake the numbers so we can return Reads object until we get better API
        fake_array = []
        puts "result key: " << result[key]
        1.upto(result[key]) do |i|
          fake_array << 1
        end
        result[key] = fake_array
      end
    end
    
    return Reads.new result, @n
  end
  
  def discard_if_present_in!(sequence)
    @n_mers = discard_if_present_in sequence
  end
end
