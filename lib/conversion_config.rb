Dir["./lib/processors/*.rb"].each {|file| require file }

module Cdl
  class ConversionConfig
   
    attr_reader :record_merge_identifier, :split_on_fields
    
    attr_reader :import_mappings, :import_mappings_reverse
    attr_reader :export_mappings, :export_mappings_reverse
    
    attr_reader :import_conversion_rules, :export_conversion_rules
    
    attr_reader :rejection_rules, :move_as_is
   
    # ----------------------------------------------------------------------------------
    def initialize(yaml)
      @split_on_fields, @rejection_rules = {}, {}
      
      @import_mappings, @export_mappings = {}, {}
      
      @import_conversion_rules, @export_conversion_rules = {}, {}
      
      # If the specified config extends another, load the super first
      unless yaml['extends'].nil?
        # Build the config for the parent and then add those settings to this class
        base_config = YAML.load_file("./config/convert/#{yaml['extends']}.yml")
        base = Cdl::ConversionConfig.new(base_config) 
      
        @record_merge_identifier = base.record_merge_identifier
        @split_on_fields = base.split_on_fields
        @move_as_is = base.move_as_is
        
        @import_mappings = base.import_mappings
        @import_conversion_rules = base.import_conversion_rules
        
        @export_mappings = base.export_mappings
        @export_conversion_rules = base.export_conversion_rules
        
        @rejection_rules = base.rejection_rules
      end
      
      # Setup the import rules
      unless yaml['import'].nil?
        yaml['import'].each do |category, definition|

          case category
          # We need to move the identified fields as is
          when 'move_as_is'
            @move_as_is = definition
          
          # We need to merge separate bib and holdings into one record
          when 'record_identifier'
            @record_identifier = definition
            
          # We need to split combined bib and holdings into separate records 
          when 'split_holdings_on'
            definition.each do |marc_field|
              marc_struct = marc_field_subfields_from_string(marc_field)
              
              @split_on_fields[marc_struct[:field]] = [] if @split_on_fields[marc_struct[:field]].nil?
              @split_on_fields[marc_struct[:field]] = marc_struct[:subfields]
            end
            
          # Processors that transform the incoming data 
          when 'conversion_rules'
            definition.each do |attribute, rules|
              # If the attribute does not have any conversion rules, initialize the array
              @import_conversion_rules[attribute] = [] if @import_conversion_rules[attribute].nil? 
              
              rules_to_processors(rules).each do |proc|
                puts proc.gsub("{?}", "import") if proc.is_a?(String)
         
                @import_conversion_rules[attribute] << proc unless proc.is_a?(String)
              end
            end
            
          # Processors that determine whether or not to skip the incoming record
          when 'rejection_rules'
            definition.each do |type, rules|
              if $app_config['rejection_types'].include?(type)
                @rejection_rules[type] = [] if @rejection_rules[type].nil?
          
                rules_to_processors(rules).each do |proc|
                  puts proc.gsub("{?}", "rejection") if proc.is_a?(String)
                    
                  @rejection_rules[type] << proc unless proc.is_a?(String)
                end
                
              else
                puts "The rejection rule, #{type}, is not defined in app.yml!"
              end
            end
            
          # Field mappings for specific file format
          else 
            @import_mappings[category] = {} if @import_mappings[category].nil?
            
            definition.each do |attribute, marc_fields|
              marc_fields.each do |marc_field|
                marc_struct = marc_field_subfields_from_string(marc_field)
                
                @import_mappings[category][marc_struct[:field]] = [] if @import_mappings[category][marc_struct[:field]].nil?
                  
                @import_mappings[category][marc_struct[:field]] << {:subfield => marc_struct[:subfields], :target => attribute}
              end
            end
          end
        end
      end
      
      unless yaml['export'].nil?
        yaml['export'].each do |category, definition|
          case category
          when 'conversion_rules'
            definition.each do |attribute, rules|
              # If the attribute does not have any conversion rules, initialize the array
              @export_conversion_rules[attribute] = [] if @export_conversion_rules[attribute].nil? 
              
              rules_to_processors(rules).each do |proc|
                puts proc.gsub("{?}", "export") if proc.is_a?(String)
                  
                @export_conversion_rules[attribute] << proc unless proc.is_a?(String)
              end
            end
            
          else # specific incoming file format
            @export_mappings[category] = {} if @export_mappings[category].nil?
            
            definition.each do |attribute, marc_field|
              marc_struct = marc_field_subfields_from_string(marc_field)
                
              @export_mappings[category][attribute] = {:field => marc_struct[:field], :subfield => marc_struct[:subfields].first}
            end
          end
        end
      end
      
    end
   
private
    # ----------------------------------------------------------------------------------
    def rules_to_processors(rules)
      out = []
      
      rules.each do |type, args|
        begin
          # Make sure the processor is defined in app.yml
          if $app_config['processor_types'].include?(type)
            klass = Object.const_get("Cdl").const_get("#{to_camel_case(type)}")
            
            # Add the import processor to the array
            out << klass.new(args)
          else
            out << "The {?} processor, #{type}, is not defined in app.yml!"
          end
          
        rescue Exception => e
          out << "Unable to create the {?} processor, #{type}: #{e}"
        end
      end
      
      out
    end
    
  end
end