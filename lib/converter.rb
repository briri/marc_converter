require 'marc'

require_relative './bib.rb'
require_relative './holding.rb'
require_relative './field.rb'
require_relative './value.rb'


Dir["./lib/processors/*.rb"].each {|file| require file }
Dir["./lib/conversion/*.rb"].each {|file| require file }

module Cdl
  
  class Converter
  
    attr_accessor :rejections
  
    # ----------------------------------------------------------------
    def initialize()
      @rejections = []
    end

    # ----------------------------------------------------------------
    def convert(marc_record)
      unless reject?(marc_record)
        bib = marc_to_object(marc_record, "Bib")

        bib << split_holdings(marc_record)
      
#puts "OCLC Numbers: #{bib.find('oclc_number').values.inspect}"
#puts bibs.inspect
      end
      
      bib
    end
    
    # ----------------------------------------------------------------
    def reject?(marc_record)
      procs = {}

      $conversion_config.rejection_rules.each do |type, rules|
        rules.each do |rule|
          
          if $app_config['preprocessor_types'].include?(rule[:op]) or $app_config['postprocessor_types'].include?(rule[:op])
            begin
              klass = Object.const_get("Cdl").const_get("#{to_camel_case(rule[:op])}")
          
              procs[type] = [] if procs[type].nil?
              procs[type] << klass.new(rule[:arg])
            
            rescue Exception => e
              puts "WARNING: a rejection rule was defined for #{type} but has no processor implementation: Cdl.#{to_camel_case(rule[:op])}"
            end
          
          else
            puts "WARNING: rejection rule must be defined as a processor: #{type}"
          end
        end
      end

      out = false
      
      procs.each do |target, proc_list|
        proc_list.each do |proc|
          case target
          when 'leader'
            out = proc.process(Cdl::Value.new(marc_record.leader, "")) unless out
          
          when 'fields'
            out = proc.process(Cdl::Value.new(marc_record.tags, "")) unless out
        
          else
            puts "Unknown rejection criteria: #{target}"
          end
        end
      end
      
      @rejections << marc_record if out
      
      out
    end

    # ----------------------------------------------------------------
    def split_holdings(marc_record)
      holdings = []

      if $conversion_config.split_on_fields.nil?
        holdings << marc_to_object(marc_record, "Holding")
        
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
          
          unless $conversion_config.mappings['holding'][field.tag].nil? or current.eql?("") 
            new_rec << field 
          end
        end
        
        recs << merge_marc_bib_holdings(new_rec, marc_record) unless current.eql?("")

        recs.each do |new_marc_record|
          holdings << marc_to_object(new_marc_record, "Holding")
        end
      end
      
      holdings
    end

    # ----------------------------------------------------------------
    def marc_to_object(marc_record, class_name)
      begin
        klass = Object.const_get("Cdl").const_get(class_name)
        obj = klass.new()
      
        marc_record.each do |marc_field|
          if $conversion_config.mappings[class_name.downcase][marc_field.tag]
            $conversion_config.mappings[class_name.downcase][marc_field.tag].each do |sf|
              # Control Field so just get the value
              if sf[:subfield].eql?("")
                obj.send(:set_value, "#{sf[:target]}", marc_field.value, "#{marc_field.tag}")
              else
                # Data Field so get the specific subfield value
                obj.send(:set_value, "#{sf[:target]}", marc_field[sf[:subfield]], "#{marc_field.tag}$#{sf[:subfield]}")
              end
            end
          end
        end
      
        obj
        
      rescue Exception => e
        puts "Unable to map MARC to Cdl::#{class_name}: #{e}"
        nil
      end
    end
 
    # ----------------------------------------------------------------
    def merge_marc_bib_holdings(new_marc_rec, old_marc_rec)
      out = MARC::Record.new()
      
      # Get all of the fields from the original record that are not in the new record
      old_marc_rec.each do |field|
        if new_marc_rec[field.tag].nil? and $conversion_config.mappings['holding'][field.tag].nil?
          out << field
        end
      end
      
      new_marc_rec.each do |field|
        out << field
      end
      
      out
    end
    
  end
end