module Cdl
  class Holding
  
    attr_accessor :oclc_symbols, :location_codes, :local_catalog_ids, :holding_record_ids
    
    attr_accessor :holding_statements, :holding_summaries, :holding_years
    
    attr_accessor :gap_statements, :gap_summaries, :gap_years
  
    LEARNABLE = ["oclc_symbols", "local_catalog_ids", "holdings_record_ids", "holding_statements", "gap_statements"]
  
    # ---------------------------------------------------
    def initialize()
      @oclc_symbols, @location_codes, @local_catalog_ids, @holding_record_ids = [], [], [], []
      
      @holding_statements, @holding_summaries, @holding_years = [], [], []
      
      @gap_statements, @gap_summaries, @gap_years = [], [], []
    end

    # ---------------------------------------------------
    def ==(other)
      out = false
      
      # If the item passed has the same oclc symbol
      if other.kind_of?(Cdl.Holding)
        other.oclc_symbols.each do |symb|
          out = true if @oclc_symbols.include?(symb)
        end
        
        if out
          # If the location code is also the same
          other.location_codes.each do |code|
            out = true if @location_codes.include?(code)
          end
        
          if out
            # If either of the identifiers also match
            other.local_catalog_ids.each do |id|
              out = true if @local_catalog_ids.include?(id)
            end
          
            unless out
              other.holdings_record_ids.each do |id|
                out = true if @holdings_record_ids.include?(id)
              end
            end
          end
        end
        
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