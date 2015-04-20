module Cdl
  class NotMatches
    
    attr_accessor :regex
    
    # ------------------------------------------------
    def initialize(value)
      @regex = value
    end
    
    # ------------------------------------------------
    def process(item)
      item.val.match(@regex).nil?
    end
    
  end
end