module Cdl
  class Bib
    
    attr_accessor :pissns, :eissns, :lccns, :oclc_numbers

    attr_accessor :titles, :short_titles, :gov_doc_values
    
    attr_accessor :corporate_names, :publishers, :publication_histories
  
    attr_accessor :subject_codes, :lc_classes, :subjects
    
    attr_accessor :linking_issns, :former_issns, :former_titles
    
    attr_accessor :holdings, :data_as_is
    
    # ---------------------------------------------------
    def initialize
      @pissns, @eissns, @lccns, @oclc_numbers = [], [], [], []
      @titles, @short_titles, @gov_doc_values = [], [], []
      @corporate_names, @publishers, @publication_histories = [], [], []
      @subject_codes, @lc_classes, @subjects = [], [], []
      
      @linking_issns, @former_issns, @former_titles = [], [], []
      
      @holdings, @data_as_is = [], []
    end
    
    # ---------------------------------------------------
    def each
      @holdings.each do |hld|
        yield hld
      end
    end
    
    # ---------------------------------------------------
    def <<(holding)
      if holding.is_a?(Array)
        holding.each do |hld|
          @holdings << hld
        end
        
      else
        @holdings << holding
      end
    end
    
    # ---------------------------------------------------
    def ==(other)
      out = false
      
      # If the item passed in is the correct type
      if other.kind_of?(Cdl::Bib)
        # Test each identifier until we find a match
        other.pissns.each do |pissn|
          out = true if @pissns.include?(pissn)
        end
        
        other.eissns.each do |eissn|
          out = true if @eissns.include?(eissn)
        end
        
        other.lccns.each do |lccn|
          out = true if @lccns.include?(lccn)
        end
        
        other.oclc_numbers.each do |oclc_number|
          out = true if @oclc_numbers.include?(oclc_number)
        end
      end
      
      out 
    end
    
    # ---------------------------------------------------
    def to_s
      out, attr_prefix = "Cdl::Bib - \n", "    "
      
      self.instance_variables.each do |var|
        if var.id2name.eql?("@holdings")
          @holdings.each do |hldg|
            out = out + hldg.to_s
          end
          
        else
          unless self.instance_variable_get("#{var}").empty? or var.id2name.eql?("@data_as_is")
            out = out + attr_prefix + "#{var} => #{self.instance_variable_get("#{var}")}\n" 
          end
        end
      end
      
      out
    end
   
  end
end