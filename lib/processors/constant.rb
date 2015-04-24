module Cdl
  class Constant
    
    attr_accessor :value
    
    # ------------------------------------------------
    def initialize(value)
      @value = value['value']
    end
    
    # Just return the constant
    # ------------------------------------------------
    def process(items)
      if items.is_a?(Array)
        [@value]
      else
        @value
      end
    end
    
  end
end