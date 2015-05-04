module Cdl
  class Extract
    
    attr_accessor :regex
    
    # ------------------------------------------------
    def initialize(value)
      @regex = /#{value}/
    end
    
    # ------------------------------------------------
    # Returns the item(s) if it matched and an empty string if it did not
    def process(items)      
      out = []
      
      if items.is_a?(Array)
        items.each do |item|
          out << item.scan(@regex).flatten
        end
        
      elsif items.is_a?(String)
        out = items.scan(@regex).flatten#{|m| m.to_s}
        
      else
       out =  items
      end
    
      out.flatten
    end
    
  end
end