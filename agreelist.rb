require 'rubygems'
require 'fluidinfo'
require 'app/models/opinator'
require 'app/models/statement'
require 'horse'
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
