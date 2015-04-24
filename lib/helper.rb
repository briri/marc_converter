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