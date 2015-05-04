require 'redis'
require 'json'

require_relative './memory.rb'
require_relative './student.rb'

module Cdl
  class StudyHall
   
    attr_reader :disciplines
   
    # --------------------------------------------------------------
    def initialize(source=nil)
      @redis = Redis.new({:host => $app_config['redis_host'], 
                          :port => $app_config['redis_port']})
                          
      @sources, @disciplines, @knowledge = [], [], {}
      
      # Retrieve the data from Redis
      @redis.keys('*').each do |key|
        @sources = JSON.parse(@redis.get(key)) if key.eql?('sources')
        
        unless key.eql?('sources')
          @knowledge[key] = []
          
          @disciplines << key
          
          memories = JSON.parse(@redis.get(key))
          
          memories.each do |memory|
            @knowledge[key] << Cdl::Memory.new(memory)
          end
        end
      end

      # If the file has already been run we should not allow students to study it
      @skip = @sources.include?(source)
      
      @sources << source unless @skip
    end
    
    # --------------------------------------------------------------
    def finish
      store_memories
      
      #@redis.flushall
    end
    
    # --------------------------------------------------------------
    def study_cdl_object(obj)
      unless @skip
        student = Cdl::Student.new
        
        obj.instance_variables.each do |var|      
          values = obj.instance_variable_get("#{var}")
          
          if values.is_a?(Array) or values.is_a?(String)
            student.learn(var.slice(1..(var.size)), values)
          end
        end
        
        consolidate_knowledge(student.memories)
      end
    end
    
    # --------------------------------------------------------------
    def study_marc_record(record)
      
    end
    
    # --------------------------------------------------------------
    def share_knowledge(discipline)
      @knowledge[discipline]
    end
    
    # --------------------------------------------------------------
    def add_verified_formula(discipline, pattern)
      # Initialize this discipline if it is new
      @disciplines << discipline unless @disciplines.include?(discipline)
      @knowledge[discipline] = [] unless @knowledge.include?(discipline)
      
      unless pattern.nil? or !
        if @knowledge[discipline].include?(pattern)
          # The pattern exists so get the existing one and set it to verified
          current = @knowledge[discipline].find{|memory| memory.pattern.eql?(pattern)}
          current["verified"] = true
          
          idx = @knowledge[discipline].index{|memory| memory.pattern == current.pattern}

          @knowledge[discipline][idx] = current
          
        else
          # This pattern does not already exist so create one
          @knowledge[discipline] << Cdl::Memory.new(:pattern => pattern, :occurences => 0, :verified => true, :examples => [])
        end
      end
    end
    
private
    # --------------------------------------------------------------
    def consolidate_knowledge(knowledge)
      # Loop through the newfound knowledge and update the existing knowledge
      knowledge.each do |discipline, memories|
        @knowledge[discipline] = [] if @knowledge[discipline].nil?
        
        memories.each do |memory|
          idx = @knowledge[discipline].index{|mem| mem.pattern.eql?(memory.pattern)}
          
          if idx.nil?
            # Add the new memory
            @knowledge[discipline] << memory
            
          else
            current = @knowledge[discipline][idx]
            
            # Add the occurences to the exisitng record along with the examples (keeping the new examples over the old)
            current.occurences = current.occurences + memory.occurences
            current.examples = (memory.examples << current.examples).flatten
            current.examples = current.examples[0..4]
            
            # Replace the old memory
            @knowledge[discipline][idx] = current
          end
        end
      end
    end
    
    # --------------------------------------------------------------
    def store_memories
      study
    
      # Record the source
      @redis.set("sources", @sources)
      
      # Put the local memories into Redis
      @knowledge.each do |discipline, memories|
        @redis.set("#{discipline}", memories.collect{|memory| memory.to_json}) unless memories.empty?
      end
    end
    
    # --------------------------------------------------------------
    def study
      # If the type has been defined and the input source has not been recorded
      unless @skip
=begin
        # The system will record the following patterns as separate memories:
        #    ^[a-zA-Z]{3}\s[a-zA-Z]{6}
        #    ^[a-zA-Z]{3}\s[a-zA-Z]{8}
        #    ^[a-zA-Z]{2}\s[a-zA-Z]{6}
        #    ^[a-zA-Z]{2}\s[a-zA-Z]{30}
        #
        # We should consolidate these entries into something more concise like:
        #    ^[a-zA-Z]{2,3}\s[a-zA-Z]{6,30}
        patterns = @knowledge.values.collect{|mem| mem.pattern}
          
        chr_arrays = []
        
        patterns.each do |pattern|
          chr_arrays << pattern.split("")
        end
        
puts "#{patterns}"
        
        chr_arrays.each do |array|
          
        end
=end        
        @knowledge.each do |discipline, memories|
          # Get the average number of occurences between all of the patterns stored
          avg = memories.collect{|memory| memory.occurences}.inject{|sum, el| sum + el}.to_f / memories.size

          # Delete any pattern who's number of occurences is below the average
          memories.delete_if{|memory| (memory.occurences.to_i <= avg) and !memory.verified} unless memories.size < 5
        end
      end
    end

  end
end