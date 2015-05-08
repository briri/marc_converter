require 'marc'

module Cdl
  class Writer
    
    # ----------------------------------------------------------------
    def initialize(type, file)
      @writer = MARC::Writer.new(file)
      
      @mappings = $app_config['exports_to_marc'][type]
    end
    
    # ----------------------------------------------------------------
    def write(bib)
      recs = bib_to_marc(bib)
      
      recs.each do |rec|
      
puts "------------------------------------------------"
puts rec
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
      bib_rec = obj_to_marc(bib)
      
      # Process the holdings
      bib.instance_variable_get("@holdings").each do |hld|
        hld_rec = obj_to_marc(hld)
        
        bib_clone = MARC::Record.new()

        bib_rec.fields.each do |fld|
          bib_clone << fld
        end
        
        hld_rec.fields.each do |fld|
          bib_clone << fld
        end

        recs << bib_clone
      end

      if recs.empty?
        recs << bib_rec
      end

      recs
    end
    
    # ----------------------------------------------------------------
    def obj_to_marc(obj)
      rec = MARC::Record.new()
      
      @mappings.each do |key, marc_def|
        obj_fld = obj.instance_variable_get("@#{key}")

        unless obj_fld.nil?
          marc_struct = marc_field_subfields_from_string(marc_def['field'])

puts obj_fld.values

          obj_fld.values.each do |v|
            # If there are no subfields defined then we have a ControlField
            if marc_struct[:subfields].nil?
puts "out: #{v.class}"
              
              rec << MARC::ControlField.new(marc_struct[:field], v.to_s) unless v.nil?
            
            else
              marc_struct[:subfields].each do |sf|
                if rec[marc_struct[:field]].nil?
                  rec << MARC::DataField.new(marc_struct[:field], ' ', ' ', MARC::Subfield.new(sf, v.to_s)) unless v.nil?
                  
                else
                  rec[marc_struct[:field]].append(MARC::Subfield.new(sf, v.to_s)) unless v.nil?
                end
              end
            end
          end
          
        end
      end
      
      rec
    end
    
  end
end