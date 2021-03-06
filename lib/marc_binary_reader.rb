require 'marc'

require_relative 'bib.rb'
require_relative 'holding.rb'

module Cdl
  class MarcBinaryReader
   
    attr_accessor :rejections, :bibs
   
    # -----------------------------------------------------------------------
    def initialize(file)
      @rejections = {}
      @bibs = []
      
      @reader = MARC::Reader.new(file)
    end
    
    # -----------------------------------------------------------------------
    def process
      @reader.each do |record|
        unless reject?(record)
          bib = marc_to_bib(record)
          idx = nil

          # If the config tells us to merge records, find the matching bib
          if $conversion_config.record_merge_identifier
            idx = bibs.find_index{|b| b == bib}
          end
          
          # If there was no need to merge the bib, add it otherwise add the holdings to the existing bib
          if idx.nil?
            bibs << bib
          else
            bibs[idx] << bib.holdings
          end
          
        end
      end
    end
    
    
private
    # ----------------------------------------------------------------
    def reject?(marc_record)
      out = false
      
      $conversion_config.rejection_rules.each do |type, procs|
        procs.each do |proc|
          unless out
            
            case type
            when 'leader'
              out = proc.process(marc_record.leader)

            when 'fields'
              out = proc.process(marc_record.tags)
            end

            if out
              # record the failure
              @rejections[type] = {} if @rejections[type].nil?
              @rejections[type][proc.to_s] = [] if @rejections[type][proc.to_s].nil?
              @rejections[type][proc.to_s] << marc_record
            end
          
          end
        end
      end
      
      out
    end
    
    # ----------------------------------------------------------------
    def marc_to_bib(marc_record)
      bib = Cdl::Bib.new()
    
      marc_record.each do |marc_field|
        if !$conversion_config.import_mappings['marc'][marc_field.tag].nil?
          
          $conversion_config.import_mappings['marc'][marc_field.tag].each do |hash|
            unless bib.instance_variable_get("@#{hash[:target]}").nil?
              extract_values_from_marc(bib, marc_field)
            end
          end
          
        end
        
        unless $conversion_config.move_as_is.nil?
          if $conversion_config.move_as_is.include?(marc_field.tag)
            bib.data_as_is << marc_field
          end
        end
      end
    
      bib << split_holdings(marc_record)
      
      bib
    end
    
    # ----------------------------------------------------------------
    def marc_to_holding(marc_record)
      holding = Cdl::Holding.new()
    
      marc_record.each do |marc_field|
        if !$conversion_config.import_mappings['marc'][marc_field.tag].nil?
          
          $conversion_config.import_mappings['marc'][marc_field.tag].each do |hash|
            extract_values_from_marc(holding, marc_field)
          end
          
        end
      end
    
      holding
    end
    
    # ----------------------------------------------------------------
    def split_holdings(marc_record)
      holdings = []

      if $conversion_config.split_on_fields.nil?
        holdings << marc_to_holding(marc_record)
        
      else
        tags = $conversion_config.split_on_fields.keys
        recs = []
        
        new_rec = MARC::Record.new()
        current = "" 
        
        marc_record.each do |field|
          if tags.include?(field.tag)

            $conversion_config.split_on_fields[field.tag].each do |sf|
              unless field[sf].nil?
                unless current.eql?(field[sf])
                  recs << merge_marc_bib_holdings(new_rec, marc_record) unless current.eql?("")
                
                  new_rec = MARC::Record.new()
                  current = field[sf]
                end
              end
            end
          end
          
          unless $conversion_config.import_mappings['marc'][field.tag].nil? or current.eql?("") 
            new_rec << field 
          end
        end
        
        recs << merge_marc_bib_holdings(new_rec, marc_record) unless current.eql?("")

        recs.each do |new_marc_record|
          holdings << marc_to_holding(new_marc_record)
        end
      end
      
      holdings
    end
   
    # ----------------------------------------------------------------
    def extract_values_from_marc(obj, marc_field)
      #puts marc_field.inspect
      #puts "Current: #{current_vals}"
      
      $conversion_config.import_mappings['marc'][marc_field.tag].each do |hash|
        unless obj.instance_variable_get("@#{hash[:target]}").nil?
          out = obj.instance_variable_get("@#{hash[:target]}")
          recorder = obj.recorder

          hash[:subfield].each do |sf|
            # Control Field so just get the value 
            if sf.eql?("")
              out << marc_field.value unless out.include?(marc_field.value)
            
            elsif sf.eql?("ALL")
              # Data Field but we should retrieve ALL the subfield values
              marc_field.each do |subfield|
                out << subfield.value unless out.include?(subfield.value)
              end
            
            else
              # Data Field so get the specific subfield value
              unless marc_field[sf].nil? or out.include?(marc_field[sf])
                out << marc_field[sf] 
                
                # Add the field+subfield << value - this is used when exporting if the config requires hierarchical
                # selection of values (e.g. if the record has no 866$a then use 863$i. If no 863$i use 863$a)
                recorder["#{marc_field.tag}$#{sf}"] = [] if recorder["#{marc_field.tag}$#{sf}"].nil?
                recorder["#{marc_field.tag}$#{sf}"] << marc_field[sf]
              end
            end
          end
          
          results = []
          out.each do |val|
            result = apply_processors('ALL', val)
          
            # If it passed the ALL test, pass it along to the specific subfield processors
            if !results.include?(result) and !result.eql?("")
              result = apply_processors(hash[:target], result)
          
              results << result if !results.include?(result) and !result.eql?("")
            end
          end
        
          obj.instance_variable_set("@#{hash[:target]}", results)
        end
      end
      
    end
    
    # ----------------------------------------------------------------
    def merge_marc_bib_holdings(new_marc_rec, old_marc_rec)
      out = MARC::Record.new()

      # Get all of the fields from the original record that are not in the new record
      old_marc_rec.each do |field|
        if new_marc_rec[field.tag].nil? #and $conversion_config.import_mappings['marc'][field.tag].nil?
          out << field
        end
      end
      
      new_marc_rec.each do |field|
        out << field
      end
      
      out
    end
    
    # ----------------------------------------------------------------
    def apply_processors(subfield, value)
      out = value
      
      # Apply any import processors that should run against ALL input fields
      unless $conversion_config.import_conversion_rules[subfield].nil?
        $conversion_config.import_conversion_rules[subfield].each do |proc|
          result = proc.process(value)

          if !!result == result
            # The processor has a true/false return so only keep the val if true
            out = (result ? value : "")
            
          else
            # The processor transformed the value so use the transformed value
            out = result
          end
        end
        
      end

      out
    end
    
  end
end