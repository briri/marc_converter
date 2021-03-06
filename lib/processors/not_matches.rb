module Cdl
  class NotMatches
    
    attr_accessor :regex
    
    # ------------------------------------------------
    def initialize(value)
      @regex = value
    end
    
    # ------------------------------------------------
    def process(items)
      if items.is_a?(Array)
        out = []
        
        items.each do |item|
          out << item.match(@regex).nil?
        end
      
        !out.include?(false)
        
      elsif items.is_a?(String)
        items.match(@regex).nil?
      
      else
        items
      end
    end
    
  end
end