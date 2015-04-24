module Cdl
  class Concatenate
    attr_accessor :delimiter

    # ------------------------------------------------
    def initialize(delimiter=" ")
      @delimiter = delimiter
    end

    # ------------------------------------------------
    def process(items)          
      if items.is_a?(Array)
        out = ""
        
        items.each do |item|
          if item.is_a?(String)
            out = out + (item.strip.nil? ? item : item.strip)
          end
        end
        
        out
        
      else
        items
      end
  
    end
    
  end
end