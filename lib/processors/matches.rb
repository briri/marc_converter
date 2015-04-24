module Cdl
  class Matches
    
    attr_accessor :regex
    
    # ------------------------------------------------
    def initialize(value)
      @regex = value
    end
    
    # ------------------------------------------------
    # Returns the item(s) if it matched and an empty string if it did not
    def process(items)      
      if items.is_a?(Array)
        out = []
        
        items.each do |item|
          out << !item.match(@regex).nil?
        end
      
        out
        
      elsif items.is_a?(String)
        !items.match(@regex).nil?
      
      else
        items
      end
      
    end
    
  end
end