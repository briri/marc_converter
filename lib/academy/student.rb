require_relative './memory.rb'

module Cdl
  class Student
    
    attr_accessor :memories
    
    SPECIAL = /[\\\^\$\.\|\?\*\+\(\)\[\]\{\}]/
    ALPHA = /[a-zA-Z]/
    NUMERIC = /[0-9]/
    SPACE = /\s/
  
    # --------------------------------------------------------------
    def initialize
      @memories = {}
    end
  
    # --------------------------------------------------------------
    def learn(discipline, values)
      @memories[discipline] = [] if @memories[discipline].nil?

      # The student can only evaluate string data!
      if values.kind_of?(Array)
        values.each{|item| memorize(discipline, item) if item.is_a?(String)}
        
      elsif values.is_a?(String)
        memorize(discipline, values)
      end
    end
    
private
    # --------------------------------------------------------------
    def memorize(discipline, value)
      if value.is_a?(Array)
        value.each{|val| memorize(val)}
      
      else
        unless value.nil?
          current = @memories[discipline].find{|memory| !value.match(memory.pattern).nil?}
  
          transformed = current.nil? ? "^" : current.pattern
  
          if current.nil?
            # Iterate through the characters and build a RegExp that represents the value
            unless value.eql?("") 
              prior, seg_type, counter = "", determine_char_type(value.slice(0,1)), 0
  
              value.split("").each do |character|
                unless character.eql?("")
                  if !character.match(seg_type).nil?
                    # Same character type
                    counter = counter + 1
        
                  else
                    chr = (seg_type.eql?(SPECIAL) ? "[\\#{prior}]" : ((seg_type.eql?(ALPHA) and counter == 1) ? "#{prior}" : seg_type.source))
                    transformed = "#{transformed}#{chr}#{counter > 1 ? "{#{counter}}" : ""}"
    
                    seg_type = determine_char_type(character)
                    counter = 1
                  end
    
                  prior = character
                end
              end
  
              chr = (seg_type.eql?(SPECIAL) ? "[\\#{prior}]" : ((seg_type.eql?(ALPHA) and counter == 1) ? "#{prior}" : seg_type.source))
              transformed = "#{transformed}#{chr}#{counter > 1 ? "{#{counter}}" : ""}"
            end

            # Add the memory if a regex was built
            unless transformed.eql?("^")
              @memories[discipline] << Cdl::Memory.new(:pattern => transformed, :occurences => 1, :verified => false, :examples => [value])
            end
    
          else
            # This is another occurence of an existing memory so increment the occurences and store the example
            current.occurences = current.occurences.to_i + 1
            current.examples << value unless current.examples.size >= 10 or current.examples.include?(value)
    
            idx = @memories[discipline].index{|memory| memory.pattern == current.pattern}
    
            @memories[discipline][idx] = current
          end
        end
      end
    end

    # --------------------------------------------------------------
    def determine_char_type(character)
      # Determine which regex to use for the character specified
      (!character.match(SPECIAL).nil? ? SPECIAL : 
        (!character.match(ALPHA).nil? ? ALPHA : 
          (!character.match(NUMERIC).nil? ? NUMERIC : 
            (!character.match(SPACE).nil? ? SPACE : /[#{character}]/))))
    end
    
  end
end
