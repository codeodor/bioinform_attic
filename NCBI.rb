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
    return convert_to_local(http_response)  
  end
  
  def self.blastx_textified(sequence, database="nr", wait=3)
    html_version = blastx(sequence, database, wait)
    begin
      
    desc_start_marker  = '<div id="descriptions" class="blRes">'
    desc_end_marker = '</div><!--/#descriptions-->'
    desc_start = html_version.index(desc_start_marker) + desc_start_marker.length
    desc_end = html_version.index(desc_end_marker) - 1
    dirty_description = html_version[desc_start..desc_end].gsub(/<\/pre>/,'').gsub(/<pre>/,'')
    
    cnt = 0
    clean_description = "Blastx results:\nSequence Code\tName\tScore (Bits)\tE-Value\tDB Link\tGene Link\n"
    
    num_lines = dirty_description.split("\n").size
    dirty_description.each_line do |line|
      cnt+=1
      if cnt >= 6 && cnt <= num_lines
        begin
        urlsplit = line.split('"')
        db_link = urlsplit[1]
        gene_link = urlsplit[3]
        
        fieldsplit = line.split(/   */)
        code = fieldsplit[0].gsub(/<(.|\n)*?>/, '').strip
        name = fieldsplit[1].strip
        score = fieldsplit[2].gsub(/<(.|\n)*?>/, '').strip
        evalue = fieldsplit[3].gsub(/<(.|\n)*?>/, '').strip
        
        new_line = code.to_s + "\t" + name.to_s + "\t" + score.to_s + "\t" + evalue.to_s + "\t" + db_link.to_s + "\t" + gene_link.to_s + "\n"
        clean_description << new_line
        rescue
          #we're on the last line, don't worry about it
        end
      end
    end
    
    rescue 
      puts "Problem! HTML was: " + html_version
      clean_description = "No significant similarity found."
    end
    
    return clean_description
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
    return params[:Status] == 'READY' || params[:Status] == 'UNKNOWN'
  end

  def self.convert_to_local(html)
    # TODO: this is fragile and breaks if NCBI changes. Best thing to do would be to find all 
    # relative urls in the output and download the assets, changing the html as appropriate
    html.gsub! "href=\"css", "href=\"ncbi_assets";
    html.gsub! "href=\"Blast.cgi?", "href=\"http://www.ncbi.nlm.nih.gov/blast/Blast.cgi?"
    html.gsub! "href=\"/blast", "href=\"http://www.ncbi.nlm.nih.gov/blast"
    html.gsub! "src=\"images", "src=\"ncbi_assets"
    html.gsub! "action=\"Blast.cgi\"", "action=\"http://www.ncbi.nlm.nih.gov/blast/Blast.cgi"
    html.gsub! "src=\"js", "src=\"ncbi_assets"
    html.gsub! "src=\"css/images", "src=\"ncbi_assets"
    html.gsub! "href=\"/books", "href=\"http://www.ncbi.nlm.nih.gov/books"
    return html
  end
end