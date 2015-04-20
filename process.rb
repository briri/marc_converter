require 'yaml'
require 'marc'

require_relative './lib/converter.rb'
require_relative './lib/conversion_config.rb'

require_relative './lib/field.rb'

# -----------------------------------------------------------------------
# Start the job
# -----------------------------------------------------------------------
$app_config = YAML.load_file('./config/app.yml')
$conversion_config = Cdl::ConversionConfig.new(YAML.load_file("./config/convert/#{ARGV[0]}.yml"))

puts "Started: #{Time.now}."

# Define the Converter 
converter = Cdl::Converter.new()

bibs = []
reader = MARC::Reader.new(ARGV[1])#, :external_encoding => "MARC-8")

reader.each do |record|  
  bib = converter.convert(record)

puts bib.holdings.inspect if bib.holdings.size > 1

  # Do merge handling here and identify duplicates!

  bibs << bib
end

puts "Rejected records: #{converter.rejections.count}"

puts "Finished: #{Time.now}."
