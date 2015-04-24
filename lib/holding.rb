module Cdl
  class Holding
  
    attr_accessor :oclc_symbol, :location_code, :local_catalog_id, :holdings_record_id
    
    attr_accessor :holdings_statement, :holdings_summary, :holdings_original
    
    attr_accessor :gaps_statement, :gaps_summary, :gaps_original
  
    # ---------------------------------------------------
    def initialize()
      @oclc_symbol, @location_code, @local_catalog_id, @holdings_record_id = "", "", "", ""
      
      @holdings_statement, @holdings_summary, @holdings_original = "", "", ""
      
      @gaps_statement, @gaps_summary, @gaps_original = "", "", ""
    end

    # ---------------------------------------------------
    def ==(other)
      out = false
      
      # If the item passed in is the correct type
      if other.kind_of?(Cdl.Holding)
        out = other.oclc_symbol.eql?(@oclc_symbol) and other.location_code.eql?(@location_code)
        
        out = (other.local_catalog_id.eql?(@local_catalog_id) or other.holdings_record_id.eql?(@holdings_record_id)) if out
        
        out
      end
      
      out
    end
    
    # ---------------------------------------------------
    def to_s
      out, attr_prefix = "    Cdl::Holding - \n", "        "
      
      self.instance_variables.each do |var|
        unless self.instance_variable_get("#{var}").empty?
          out = out + attr_prefix + "#{var} => #{self.instance_variable_get("#{var}")}\n" 
        end
      end
      
      out
    end
    
  end
end