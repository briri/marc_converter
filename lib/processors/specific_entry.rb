module Cdl
  class SpecificEntry
    
    # --------------------------------------------
    def initialize(rule)
      if rule.kind_of?(Hash)
        @position = rule['position'] unless rule['position'].nil?
        @field_order = nil
      end
    end
    
    # --------------------------------------------
    def process(items)
      opts = []

      if @field_order.nil?
        opts << items
    
      else
        # If a specific order was specified, sort the fields accordingly
        @field_order.each do |ord|
          opts << items.find_all{ |item| item[:marc_source => ord] }
        end
      end

      case @position
      when "first" # Return the 1st item
        opts.first
    
      when "last" # Return the last item
        opts.last
    
      else # Return the specified item if possible otherwise return the first item
        opts[@position.to_i].nil? ? opts.first : opts[@position.to_i]
      end
      
    end
  end
end