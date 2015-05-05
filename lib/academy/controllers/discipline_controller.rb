require_relative '../study_hall.rb'
require_relative '../../helper.rb'

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

puts "Pattern: #{patterns[0]}"

puts "Sliced: #{patterns[0].split(/{\d}/)}"

puts "Matched 1: #{patterns[0].match(/\[[a-zA-Z0-9]+\]/)}"
puts "Matched 2: #{patterns[0].match(/\{\d+\}/)}"

cntr, parts, sizes = 0, {}, {}

patterns.each do |pattern|
  pat = pattern_to_hash(pattern.to_s)
  
  unless pat.nil?
    parts[cntr] = pat
    sizes[cntr] = pat.size
    cntr += 1
  end
end

sz = sizes.values.uniq.sort.reverse#_by{|k,v| v}
sorted = []

sz.each do |s|
  sizes.find_all{|k,v| v.eql?(s)}.each do |key, value|
    sorted << parts[key]
  end
end

i, out, current = 0, {}, ""

while i < (sorted[0].size - 1)
  prior = current
  
  
  sorted.each do |parts|
puts parts[i]
puts "**************"
    
    current = "#{prior}#{parts[i].to_s}"
    
    unless parts[i].nil?

puts "#{prior} <--> #{current}"
puts parts[i]
      
      if !parts[i].match(/\{\d\}/).nil?
        masked = "#{current.sub(/\{\d\}/, '{?}')}"
        nbr = parts[i][(parts[i].index('{') + 1)]
      
        if out[prior].nil?
          out[masked] = [nbr]
          
        else
          out[masked] = (out[prior] << nbr).uniq
          out.delete(prior)
        end
      
      else
        if out[current].nil?
          out[current] = []
        
          out.delete(prior)
        end
      end
    end
  end
  
  i += 1
end

puts "--------------------------------------------------------------"
puts "#{out}"



=begin
patterns.each do |pattern|
  a, pos, old, cntr = "", 0, 0, 1
  
  while !pos.nil? and !a.nil?
    old = pos + a.to_s.size unless a.nil?
  
    a = pattern.match(/\{\d+\}/, old + 1)
    pos = pattern.index(a.to_s, old + 1)
  
    unless pos.nil?
      before = pattern[old..(pos - 1)]
      parts[cntr] = {} if parts[cntr].nil?
      parts[cntr][before] = [] if parts[cntr][before].nil?
      
      parts[cntr][before] << a.to_s.sub('{','').sub('}','').to_i unless parts[cntr][before].include?(a)
      cntr += 1
    end
  end
end

puts parts

parts.each do |pos, pattern|
  pattern.each do |p, lengths|
    sects, curr, i, j = [], "", 0, 0
  
    i = 1 if p.start_with?('^')
    
    while !curr.nil?
      curr = p.match(/\[.+\]/, i + 1)
      j = p.index(curr.to_s, i + 1)
    
      unless j.nil?
        s = p[i..(j - 1)]
        sects << s
      end
    end
  
    puts "section #{pos} - #{p} >> #{sects}"
  end
end
=end
# ^ [ \ ( ] [ a - z A  -  Z  ]  {  5  }  [  \  )  ]  [  0  -  9  ]  {  8  }
# 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28

# 0 - 13  |  14 - 16  |  17 - 25  | 26 - 28

      erb :discipline
    end
    
  end
end