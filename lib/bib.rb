module Cdl
  class Bib
    
    attr_accessor :identifiers
    attr_accessor :holdings
  
    # ---------------------------------------------------
    def initialize()
      @holdings, @identifiers = [], []
      
      # Construct the fields and identifiers based on the configuration settings
      $app_config['bib_definition'].each do |fld|
        instance_variable_set("@#{fld}", Cdl::Field.new(fld))
        
        @identifiers << instance_variable_get("@#{fld}").name if $app_config['bib_identifiers'].include?(fld)
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
    def each
      @holdings.each do |hld|
        yield hld
      end
    end
    
    # ---------------------------------------------------
    def <<(holding)
      if holding.is_a?(Array)
        holding.each do |hld|
          @holdings << hld
        end
        
      else
        @holdings << holding
      end
    end
    
    # ---------------------------------------------------
    def ==(other)
      # If the item passed in is the correct type
      if other.kind_of?(self.class)
        out = false
        
        # Test each identifier until we find a match
        @identifiers.each do |name|
          my_var = instance_variable_get("@#{name}")
          other_var = other.instance_variable_get("@#{name}")
          
          unless other_var.nil?
            my_var.values.each do |val|
              out = other_var.values.include?(val) unless out
            end
          end
        end
          
        out
        
      else
        false
      end
    end
     
  end
end