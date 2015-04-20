module Cdl
  class Holding
  
    attr_accessor :identifiers
  
    # ---------------------------------------------------
    def initialize()
      @identifiers = []
      
      # Construct the fields and identifiers based on the configuration settings
      $app_config['holding_definition'].each do |fld|
        instance_variable_set("@#{fld}", Cdl::Field.new(fld))
        
        @identifiers << instance_variable_get("@#{fld}") if $app_config['holding_identifiers'].include?(fld)
      end
      
    end

    # ---------------------------------------------------
    def find(attr)
      instance_variable_get("@#{attr}")
    end
    
    # ---------------------------------------------------
    def set_value(attr, value, source)
      unless instance_variable_get("@#{attr}").nil?
        fld = instance_variable_get("@#{attr}")
        
        fld << Value.new(value, source)
        
        instance_variable_set("@#{attr}", fld)
      end
    end

    # ---------------------------------------------------
    def ==(other)
      # If the item passed in is the correct type
      if other.kind_of?(self.class)
        out = true
        
        # All identifiers must match!
        @identifiers.each do |id|
          out = (id.value == other.instance_variable_get("@#{id.name}").value) if out
        end
      
        out
      else
        false
      end
    end
    
  end
end