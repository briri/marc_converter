module Cdl
  class Matches
    
    attr_accessor :regex
    
    # ------------------------------------------------
    def initialize(value)
      @regex = value
    end
    
    # ------------------------------------------------
    def process(item)
      if item.is_a?(Cdl::Value) and !item.val.nil?
        !item.val.match(@regex).nil?
        
      else
        false
      end
    end
    
  end
end