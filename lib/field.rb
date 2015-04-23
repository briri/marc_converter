module Cdl
  class Field
   
    attr_accessor :name
    
    attr_accessor :preprocessors, :postprocessors
    
    # -----------------------------------------------------
    def initialize(name)
      @name = name
      
      @values = []
      
      @preprocessors, @postprocessors = [], []
      
      # Attach the processors for the conversion rules defined in the config tree
      unless $conversion_config.conversion_rules.nil?
        unless $conversion_config.conversion_rules[name].nil?

          $conversion_config.conversion_rules[name].each do |rule|
            if $app_config['postprocessor_types'].include?(rule[:type]) or $app_config['preprocessor_types'].include?(rule[:type])
              begin
                klass = Object.const_get("Cdl").const_get("#{to_camel_case(rule[:type])}")

                if $app_config['postprocessor_types'].include?(rule[:type])
                  @postprocessors << klass.new(rule[:arg])
          
                elsif $app_config['preprocessor_types'].include?(rule[:type])
                  @preprocessors << klass.new(rule[:arg])
                end
          
              rescue Exception => e
                puts "WARNING: a conversion rule was defined but has no processor implementation: #{rule[:type]} (#{e})"
              end
            else
              puts "WARNING: undefined conversion rule: #{rule[:type]}"
            end
          end
          
        end
      end
      
    end
    
    # -----------------------------------------------------
    def to_s
      "#{@name} => #{@values}"
    end
    
    # -----------------------------------------------------
    def <<(val)
      if val.is_a?(Cdl::Value)
        passed = true
        
        # Run the incoming value through all of the preprocessors
        @preprocessors.each do |processor|
          passed = processor.process(val)
        end
      
        # If the value passed all preprocessor tests add it
        @values << val if passed
      end
    end
    
    # -----------------------------------------------------
    def values=(vals)
      vals.each do |val|
        self << val
      end
    end
    
    # -----------------------------------------------------
    def values()
      if @postprocessors.empty?
        @values
        
      else
        out = []
      
        @postprocessors.each do |processor|
          out << processor.process(@values)
        end
      
        out
      end
    end
    
  end
  
end