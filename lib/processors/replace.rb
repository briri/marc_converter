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
        items.each do |item|
          if item.is_a?(Cdl::Value) and !item.val.nil?
            item.val = item.val.gsub(/#{@regex}/, @value)
          end
        end
      end
      
    end
    
  end
end