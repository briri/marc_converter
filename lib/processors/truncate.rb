module Cdl
  class Truncate
    attr_accessor :size

    # ------------------------------------------------
    def initialize(size=1)
      @size = size
    end

    # ------------------------------------------------
    def process(items)          
      if items.is_a?(Array)
        out = []
        
        items.each do |item|
          if item.is_a?(String)
            out << item.slice(0..@size)
          end
        end
        
        out
        
      elsif items.is_a?(String)
        items.slice(0..@size)
        
      else
        items
      end
  
    end
    
  end
end