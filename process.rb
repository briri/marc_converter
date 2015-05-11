require 'yaml'
require 'marc'

require_relative './lib/conversion_config.rb'
require_relative './lib/helper.rb'

require_relative './lib/marc_binary_reader.rb'
require_relative './lib/marc_binary_writer.rb'
require_relative './lib/academy/study_hall.rb'

# -----------------------------------------------------------------------
# Start the job
# -----------------------------------------------------------------------
$app_config = YAML.load_file('./config/app.yml')
$conversion_config = Cdl::ConversionConfig.new(YAML.load_file("./config/convert/#{ARGV[0]}.yml"))

puts "Started: #{Time.now}."

puts "Record Match Point: #{$conversion_config.record_merge_identifier}"
puts "Rejection Rules: #{$conversion_config.rejection_rules}"

reader = Cdl::MarcBinaryReader.new(ARGV[1])
writer = Cdl::MarcBinaryWriter.new(ARGV[2])
study_hall = Cdl::StudyHall.new(ARGV[1])

reader.process

reader.bibs.each do |bib|
#puts bib

  study_hall.study_cdl_object(bib)
  
  bib.holdings.each do |holding|
    study_hall.study_cdl_object(holding)
  end
  
  writer.write(bib)
end

study_hall.finish
writer.flush

puts "Finished: #{Time.now}."
