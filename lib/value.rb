module Cdl
  # ======================================================================
  class Value
    attr_accessor :val, :marc_source 
  
    # --------------------------------------------
    def initialize(value, source="")
      @val, @marc_source = value, source
    end
  
    # --------------------------------------------
    def to_s
      @val
    end
  end
end