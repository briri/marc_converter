require 'rubygems'
require 'bundler'

require 'yaml'
require 'sinatra'

require_relative './lib/academy/controllers/discipline_controller.rb'

$app_config = YAML.load_file('./config/app.yml')

run Cdl::MarcAcademy.new