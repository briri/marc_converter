module Cdl
  class ConversionRule
    
    attr_accessor :field
    
    attr_accessor :matches, :hard_code
    attr_accessor :use_specific_entry, :select_order
    
    attr_accessor :reject
    
    # -------------------------------------------------------------------
    def initialize(field, rules)
      @reject = false
      @field = field
      
      rules.each do |key, val|
        
        if val.kind_of?(String) and val.include?("$")
          v = marc_field_subfields_from_string(val)
        else
          v = val
        end
        
        instance_variable_set("@#{key}", val)
      end
      
    end
    
    # -------------------------------------------------------------------
    def merge(rule)
      rule.instance_variables.each do |var|
        instance_variable_set("#{var}", rule.instance_variable_get("#{var}")) unless rule.instance_variable_get("#{var}").nil?
      end
      
      self
    end
   
    # -------------------------------------------------------------------
    def valid?(val)
      out = true
      out = !val.match(@matches).nil? unless @matches.nil?
      
puts "#{val} failed validation!" unless out
      out
    end
    
  end
end