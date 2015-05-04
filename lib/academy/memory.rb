module Cdl
  class Memory
    attr_accessor :pattern, :occurences, :verified
    
    attr_accessor :examples
    
    # --------------------------------------------------------------
    def initialize(hash)
      hash = JSON.parse(hash) if hash.is_a?(String)
      
      hash.each{|k,v| send("#{k}=", v)}
      
      @examples = [] if @examples.nil?
    end
    
    # --------------------------------------------------------------
    def to_s
      "#{@verified ? "verified" : "unverified"} pattern: #{@pattern} has had #{@occurences} occurences"
    end
    
    # --------------------------------------------------------------
    def to_json
      JSON.generate({:pattern => @pattern, :occurences => @occurences, :verified => @verified, :examples => @examples})
    end
    
  end
end