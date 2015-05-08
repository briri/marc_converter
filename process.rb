require 'yaml'
require 'marc'

require_relative './lib/conversion_config.rb'
require_relative './lib/helper.rb'

require_relative './lib/marc_reader.rb'
require_relative './lib/marc_writer.rb'
require_relative './lib/academy/study_hall.rb'

# -----------------------------------------------------------------------
# Start the job
# -----------------------------------------------------------------------
$app_config = YAML.load_file('./config/app.yml')
$conversion_config = Cdl::ConversionConfig.new(YAML.load_file("./config/convert/#{ARGV[0]}.yml"))

puts "Started: #{Time.now}."

puts "Record Match Point: #{$conversion_config.record_merge_identifier}"
puts "Rejection Rules: #{$conversion_config.rejection_rules}"

reader = Cdl::MarcReader.new(ARGV[1])
study_hall = Cdl::StudyHall.new(ARGV[1])

reader.process

reader.bibs.each do |bib|
puts bib

  study_hall.study_cdl_object(bib)
  
  bib.holdings.each do |holding|
    study_hall.study_cdl_object(holding)
  end
end

study_hall.finish

puts "Finished: #{Time.now}."
