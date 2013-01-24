require 'rubygems'
require 'fluidinfo'
require 'yaml'
require 'models/opinator'
require 'models/statement'
require 'extensions/string'
class Fl
  def self.new
    begin
      credentials = YAML.load(File.open("credentials.yaml"))
      Fluidinfo::Client.new(credentials[:fluidinfo])
    rescue
      Fluidinfo::Client.new
    end
  end
end
