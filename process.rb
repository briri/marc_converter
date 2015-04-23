require 'yaml'
require 'marc'

require_relative './lib/converter.rb'
require_relative './lib/conversion_config.rb'
require_relative './lib/writer.rb'

require_relative './lib/conversion/normalizer.rb'

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

  # Do merge handling here and identify duplicates!
#  if bibs.include?(bib)
#    puts "Duplicate records detected for: #{bib.identifiers.collect{|x| "#{x.to_s}"}.join(', ')}" 
#  else
    bibs << bib
#  end
  
end

writer = Cdl::Writer.new('papr', '/mnt/source_data/2014/holdings/converted/OUT.mrc')

bibs.each do |bib|
  writer.write(bib)
end

writer.flush()

puts "Rejected records: #{converter.rejections.count}"

puts "Finished: #{Time.now}."
