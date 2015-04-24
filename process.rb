require 'yaml'
require 'marc'

require_relative './lib/conversion_config.rb'
#require_relative './lib/writer.rb'

require_relative './lib/helper.rb'
require_relative './lib/reader.rb'

# -----------------------------------------------------------------------
# Start the job
# -----------------------------------------------------------------------
$app_config = YAML.load_file('./config/app.yml')
$conversion_config = Cdl::ConversionConfig.new(YAML.load_file("./config/convert/#{ARGV[0]}.yml"))

puts "Started: #{Time.now}."

#puts $conversion_config.inspect

reader = Cdl::MarcReader.new(ARGV[1])

reader.process

reader.bibs.each do |bib|
  puts bib.to_s
  puts bib.data_as_is
  puts "--------------------------------------------"
end

#puts "Rejections: #{reader.rejections}"

puts "Finished: #{Time.now}."
