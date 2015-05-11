module Cdl
  class Replace
    
    attr_accessor :regex, :value
    
    # ------------------------------------------------
    def initialize(hash)
      @regex = hash['find']
      @value = hash['value']
    end
    
    # ------------------------------------------------
    def process(items)          
      if items.is_a?(Array)
        out = []
        
        items.each do |item|
          out << item.gsub(/#{@regex}/, @value) unless item.nil?
        end
      
        out
        
      elsif items.is_a?(String)
        items.gsub(/#{@regex}/, @value)
      
      else
        items
      end
      
    end
    
  end
end