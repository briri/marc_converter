module Cdl
  class RejectRule
    
    attr_accessor :type 
    
    attr_accessor :matches, :not_matches, :fields
    
    # ------------------------------------------------------------------------------
    def initialize(type, rules)
      @type = type
      
      rules.each do |k, v|
        instance_variable_set("@#{k}", v)
      end
    end
    
  end
end