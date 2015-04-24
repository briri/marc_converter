module Cdl
  class MissingAll
    
    attr_accessor :array
    
    # ------------------------------------------------
    def initialize(value)
      @array = value
    end
    
    # ------------------------------------------------
    def process(items)
      out = true

      @array.each do |i|
        out = !items.include?(i) if out
      end

      out
    end
    
  end
end