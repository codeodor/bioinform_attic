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

  def self.blastx(sequence, database="nr", wait=3)
    http_response = Net::HTTP.get(URI.parse("http://www.ncbi.nlm.nih.gov/blast/Blast.cgi?CMD=Put&QUERY=#{sequence}&DATABASE=#{database}&PROGRAM=blastx"))
    params = blast_results_params(http_response)
    request_id = params[:RID]
    estimated_time_of_execution = params[:RTOE].to_i
    
    until(blast_results_ready? http_response)
      sleep estimated_time_of_execution
      estimated_time_of_execution = wait
      http_response = Net::HTTP.get(URI.parse("http://www.ncbi.nlm.nih.gov/blast/Blast.cgi?RID=#{request_id}&CMD=Get"))
    end
    return http_response 
  end
  
  
  
  private
  def self.blast_results_params(http_response)
    start_marker = 'QBlastInfoBegin'
    finish_marker = 'QBlastInfoEnd'
    start = http_response.index(start_marker) + start_marker.length
    finish = http_response.index(finish_marker) - 1 
    
    param_array = http_response[start..finish].gsub(/\t/,'').gsub(' ','').split
    params = {}
    param_array.each do |x|
      name = x.split('=')[0]
      value = x.split('=')[1]
      params[name.to_sym] = value
    end
    return params
  end
  
  def self.blast_results_ready?(http_response)
    params = blast_results_params(http_response)
    return params[:Status] == 'READY'
  end

end