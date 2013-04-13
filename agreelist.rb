require 'rubygems'
require 'fluidinfo'
require 'app/models/opinator'
require 'app/models/statement'
require 'horse'
require 'extensions/string'

module Fl
  def self.new
    begin
      Fluidinfo::Client.new(user: ENV['Fluidinfo_user'], password: ENV['Fluidinfo_password'])
    rescue
      Fluidinfo::Client.new
    end
  end
end
