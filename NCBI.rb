class NCBI
  require 'net/http'
  def self.get_fasta_sequence_of_gi(gi, from='begin', to='end')
    http_response = Net::HTTP.get 'www.ncbi.nlm.nih.gov', "/entrez/viewer.fcgi?db=nucleotide&list_uids=#{gi}&dopt=fasta&from=#{from}&to=#{to}"
    
    start_search_string = '<div class=\'recordbody\'>'
    start_at = http_response.index(start_search_string) + start_search_string.length
    
    end_search_string = '</div>'
    end_at = http_response.index(end_search_string, start_at) - 1
    
    as_fasta = http_response[start_at..end_at]
    return as_fasta
  end
end