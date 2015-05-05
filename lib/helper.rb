# -------------------------------------------------------------
def marc_field_subfields_from_string(val)
  if val.include?('$')
    contents = val.split('$');    
    {:field => contents[0], :subfields => contents[1..contents.size]}
  
  else
    {:field => val, :subfields => [""]}
  end
end

# -------------------------------------------------------------
def to_camel_case(val)
  parts = val.split('_')
  parts.collect{ |part| "#{part.capitalize}" }.join('')
end

# -------------------------------------------------------------
def pattern_to_hash(pattern)
#  parts = pattern_to_array(pattern, /\{\d+\}/, '{}')

  parts = p_to_a(pattern, /\[(a-zA-Z|0-9|,|\\\\\.)\](\{\d+\})?/)  
  
puts "parts: #{parts}"

  parts  
end

# -------------------------------------------------------------
def p_to_a(pattern, match_on)
  parts, pos, last, part = ["#{pattern.slice(0,1)}"], 0, 0, ""
  
  while !pos.nil? and !part.nil?
    last = pos + part.to_s.size unless part.nil?
    
    part = pattern.match(match_on, last + 1)
    pos = pattern.index(part.to_s, last + 1)
    
    unless pos.nil?
      prior = pattern[last..(pos - 1)]
      parts << prior unless parts.nil? or last.eql?(pos - 1)

      parts << part.to_s unless last.eql?(pos - 1)
    end
  end
  
  parts << pattern[last..(pattern.size)]
  
  parts
end

# -------------------------------------------------------------
def pattern_to_array(pattern, match_on, sub_out)
  parts, part, pos, cntr = {}, "", 0, 1
  
  while !pos.nil? and !part.nil?
    old_pos = pos + part.to_s.size unless part.nil?
    
    # Break up the incoming pattern by the {#} sections
    part = pattern.match(match_on, old_pos + 1)
    pos = pattern.index(part.to_s, old_pos + 1)

    unless pos.nil?
      before = pattern[old_pos..(pos - 1)]
      parts[cntr] = [] if parts[cntr].nil?
    
      entry = part.to_s
      sub_out.split("").each do |slice|
        entry = entry.sub(slice, '')
      end
      
      unless entry.nil?
        existing = parts[cntr].find{|p, c| p.eql?(before)}
      
        if existing.nil?
          parts[cntr] << {:pattern => before, :content => entry}
        else
          existing[:content] << entry
        end
      end
      
      cntr += 1
    end
  end

  parts
end