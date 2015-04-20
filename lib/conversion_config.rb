module Cdl
  class ConversionConfig
   
    attr_reader :record_identifier, :split_on_fields
    attr_reader :mappings, :rejection_rules, :conversion_rules
   
    def initialize(yaml)
      @mappings = {'bib' => {}, 'holding' => {}}

      @record_identifier = "oclc_number"

      @rejection_rules, @split_on_fields, @conversion_rules = {}, {}, {}
      
      # If the specified config extends another, load the super first
      unless yaml['extends'].nil?
        # Build the config for the parent and then add those settings to this class
        base_config = YAML.load_file("./config/convert/#{yaml['extends']}.yml")
        base = Cdl::ConversionConfig.new(base_config) 
      
        @record_identifier = base.record_identifier
        @rejection_rules = base.rejection_rules
        @mappings = base.mappings
        @conversion_rules = base.conversion_rules
        @split_on_fields = base.split_on_fields
      end
      
      @record_identifier = yaml['record_identifier'] unless yaml['record_identifier'].nil?
      
      # Setup the MARC to object field mapping
      unless yaml['mapping'].nil?
        yaml['mapping'].each do |key, val|
          marc_struct = []
          
          bib = $app_config['bib_definition'].include?(key)
          
          # Decode the inidividual [field]$[subfield]$[subfield] markup into {:field => "999", :subfields => ['a', 'b', 'c']}
          if val.kind_of?(Array)
            val.each do |fld|
              marc_struct << marc_field_subfields_from_string(fld)
            end
          
          else
            marc_struct << marc_field_subfields_from_string(val)
          end
          
          # Reverse the mapping from the Object.field -> MARC direction
          # We will end up with something like this:
          #        {'bib': [{:field => :value => '999': [{'a': 'oclc_number'}, {'y': 'oclc_numbmer'}]}, 
          #                 {'001': 'local_catalog_id'}]}
          marc_struct.each do |struct|
            @mappings[(bib ? 'bib' : 'holding')][struct[:field]] = [] if @mappings[struct[:field]].nil?
            
            # If there is no subfield definition
            if struct[:subfields].nil?
              @mappings[(bib ? 'bib' : 'holding')][struct[:field]] << {:subfield => '', :target => key}
              
            else
              # Its a data field so work through the subfields
              struct[:subfields].each do |sf|
                @mappings[(bib ? 'bib' : 'holding')][struct[:field]] << {:subfield => sf, :target => key}
              end
            end
          end
        end
      end
      
      # Record the Split record fields
      unless yaml['split_holdings_on'].nil?
        yaml['split_holdings_on'].each do |fld|
          marc_struct = marc_field_subfields_from_string(fld)

          @split_on_fields[marc_struct[:field]] = [] if @split_on_fields[marc_struct[:field]].nil?
          @split_on_fields[marc_struct[:field]] = marc_struct[:subfields]
        end
      end
      
      # Define the record rejection rules
      unless yaml['reject_record_if'].nil?
        yaml['reject_record_if'].each do |type, rules|
          puts "WARNING: undefined rejection rule: #{type}" unless $app_config['rejection_rule_types'].include?(type) 
          
          @rejection_rules[type] = [] if @rejection_rules[type].nil?
          
          rules.each do |op, arg|
            @rejection_rules[type] << {:op => op, :arg => arg}
          end
        end
      end
      
      # Define the conversion rules
      unless yaml['conversion_rules'].nil?
        yaml['conversion_rules'].each do |field, rules|
          @conversion_rules[field] = [] if @conversion_rules[field].nil?
          
          rules.each do |type, arg|
            @conversion_rules[field] << {:type => type, :arg => arg}
          end
        end
      end
    end
    
  end
end