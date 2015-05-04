require 'yaml'
require 'marc'

require_relative './lib/conversion_config.rb'
require_relative './lib/helper.rb'

require_relative './lib/reader.rb'
require_relative './lib/writer.rb'
require_relative './lib/academy/study_hall.rb'

# -----------------------------------------------------------------------
# Start the job
# -----------------------------------------------------------------------
$app_config = YAML.load_file('./config/app.yml')
$conversion_config = Cdl::ConversionConfig.new(YAML.load_file("./config/convert/#{ARGV[0]}.yml"))

puts "Started: #{Time.now}."

#puts $conversion_config.import_conversion_rules

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
