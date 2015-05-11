require 'marc'

module Cdl
  class MarcBinaryWriter
    
    # ----------------------------------------------------------------
    def initialize(file)
      @errors = []
      
      @writer = MARC::Writer.new(file)
    end
    
    # ----------------------------------------------------------------
    def write(bib)
      recs = bib_to_marc(bib)
      
      recs.each do |rec|
        @writer.write(rec)
      end
    end
    
    # ----------------------------------------------------------------
    def flush()
      @writer.close()
    end
    
private
    # ----------------------------------------------------------------
    def bib_to_marc(bib)
      recs = []

      # Create a record for each holding
      if bib.holdings.empty?
        rec = obj_to_marc(bib)
        
        # Add any data that we need to move as is
        recs << add_as_is_data(bib.data_as_is, rec)
        
      else
        bib.holdings.each do |holding|
          rec = obj_to_marc(bib)
          
          # Add the holdings to the record
          hld_rec = obj_to_marc(holding)
          hld_rec.each do |fld| 
            rec << fld
          end
          
          # Add any data that we need to move as is
          recs << add_as_is_data(bib.data_as_is, rec)
        end
      end

      recs
    end
    
    # ----------------------------------------------------------------
    def obj_to_marc(obj)
      rec = MARC::Record.new()
      
      $conversion_config.export_mappings['marc'].each do |attribute, marc_struct|
        unless obj.instance_variable_get("@#{attribute}").nil?
          obj.instance_variable_get("@#{attribute}").each do |val|
            
            # apply export processors
            val = apply_processors('ALL', val)
        
            # If it passed the ALL test, pass it along to the specific subfield processors
            val = apply_processors(attribute, val) unless val.eql?("")

            # If there is a subfield then its a DataField otherwise a ControlField
            if marc_struct[:subfield].empty?
              rec << MARC::ControlField.new(marc_struct[:field], val)
            
            else
              subfield = MARC::Subfield.new(marc_struct[:subfield], val)
                
              # If the field already exists just add the subfield otherwise add the field
              if rec[marc_struct[:field]].nil?
                rec << MARC::DataField.new(marc_struct[:field], ' ', ' ', subfield)
              else
                rec[marc_struct[:field]].append(subfield)
              end
            end
          end
        end
      end
      
      rec 
    end
    
    # ----------------------------------------------------------------
    def apply_processors(attribute, value)
      out = value
      
      # Apply any import processors that should run against ALL input fields
      unless $conversion_config.export_conversion_rules[attribute].nil?
        $conversion_config.export_conversion_rules[attribute].each do |proc|
          result = proc.process(out)

          if !!result == result
            # The processor has a true/false return so only keep the val if true
            out = (result ? out : "")
            
          else
            # The processor transformed the value so use the transformed value
            out = result
          end
        end
        
      end

      out
    end
    
    # ----------------------------------------------------------------
    def add_as_is_data(as_is_fields, marc_rec)
      as_is_fields.each do |as_is|
        # Only attach the field if it was not already processed!
        marc_rec << as_is if marc_rec[as_is.tag].nil?
      end
      
      marc_rec
    end
    
  end
end