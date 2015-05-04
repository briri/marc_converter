require_relative '../study_hall.rb'

module Cdl
  class MarcAcademy < Sinatra::Application
  
    # -----------------------------------------------------------------
    get '/disciplines' do
      study_hall = Cdl::StudyHall.new
      
      @disciplines = study_hall.disciplines
      
      erb :disciplines
    end
  
    # -----------------------------------------------------------------
    get '/discipline/:discipline' do
      @discipline = params[:discipline]
  
      study_hall = Cdl::StudyHall.new
      
      @memories = study_hall.share_knowledge(@discipline)
      @memories = [] if @memories.nil?
      
      @memories = @memories.sort{|x,y| y.occurences <=> x.occurences}
      
patterns = @memories.collect{|mem| mem.pattern}
  
chr_arrays = []

patterns.each do |pattern|
  chr_arrays << pattern.split("")
end

sliced = patterns[0].split(/{\d}/)

# Use pattern matching to retrieve the {\d} values and consolidate them where it makes sense!

puts "Sliced: #{patterns[0].split(/{\d}/)}"

puts "Character Arrays: #{chr_arrays}"
      
# [["^", "[", "\\", "(", "]", "[", "a", "-", "z", "A", "-", "Z", "]", "{", "5", "}", "[", "\\", ")", "]", "[", "0", "-", "9", "]", "{", "8", "}"], 
# ["^", "[", "\\", "(", "]", "[", "a", "-", "z", "A", "-", "Z", "]", "{", "5", "}", "[", "\\", ")", "]", "[", "a", "-", "z", "A", "-", "Z", "]", "{", "3", "}", "[", "0", "-", "9", "]", "{", "8", "}", "\\", "s"], 
# ["^", "[", "a", "-", "z", "A", "-", "Z", "]", "{", "3", "}", "[", "0", "-", "9", "]", "{", "8", "}"]]
      
new_strs = chr_arrays.collect{|arr| "^#{arr[1]}"}

chr_arrays = chr_arrays.sort{|x,y| y.size <=> x.size}

max = chr_arrays[1].size
  
chr_arrays.each do |array|
  i = 0

  begin
    new_strs.find{|val| val[0..i].eql?(array)}
    
    i += 1
  end while i < max
end

puts "New Strings: #{new_strs}"

      erb :discipline
    end
    
  end
end