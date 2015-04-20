module Cdl
  class Constant
    
    attr_accessor :value
    
    # ------------------------------------------------
    def initialize(value)
      @value = value
    end
    
    # Just return the constant
    # ------------------------------------------------
    def process(item)
      @value
    end
    
  end
end