class FileFormats
  def self.old_to_fasta(old_filename, fasta_filename)
    name, sequence = old_to_name_and_string(old_filename)
    fasta_output = name << "\n" << sequence
    File.open(fasta_filename, 'w') do |file|
      file.write(fasta_output)
    end
  end

  def self.old_to_name_and_string(old_filename)
    name = ">"
    sequence_string = ""
    line_number_before_sequence = 4
    File.open(old_filename) do |file|
      line_count = 0
      file.each_line do |line|
        line_count += 1
        if line_count < line_number_before_sequence
          name << line.gsub(/\n/, '') 
          name << " | "  
        end
        #name << "\n" if line_count == line_number_before_sequence
        sequence_string = line if line_count > line_number_before_sequence
      end
    end
    return name, sequence_string
  end
  
  def self.fasta_to_old(fasta_filename, old_filename)
    description_line = ""
    sequence_line = ""
    File.open(fasta_filename) do |file|
      line_count = 0
      file.each_line do |line|
        line_count += 1 
        description_line = line if line_count == 1
        sequence_line << line.gsub(/\s/, "") if line_count > 1
      end
    end
    
    File.open(old_filename, 'w') do |file|
      file.write(description_line << "\n\n\n" << sequence_line)
    end
  end
  
end
#FileFormats.old_to_fasta("../potato/potato_ref_seqs/NC_007943.txt", "NC.fasta")
