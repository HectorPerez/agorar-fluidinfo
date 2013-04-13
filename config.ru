$:.unshift File.expand_path("../", __FILE__)
require 'rubygems'
require "./sinatra-app"

run Sinatra::Application
# set :environment, :development
