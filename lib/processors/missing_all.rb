module Cdl
  class MissingAll
    
    attr_accessor :array
    
    # ------------------------------------------------
    def initialize(value)
      @array = value
    end
    
    # ------------------------------------------------
    def process(item)
      out = true
      
      @array.each do |i|
        out = false if item.val.include?(i)
      end
      
      out
    end
    
  end
end