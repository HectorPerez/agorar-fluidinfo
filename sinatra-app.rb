#!/usr/bin/env ruby -I ../lib -I lib
# coding: utf-8
require 'sinatra'
require "bundler/setup"
require 'agreelist'
require 'haml'
require 'pony'

get '/' do
  logger
  haml :index
end

post '/' do
  redirect "/a/#{params[:name].gsub(' ', '_')}"
end

helpers do
  # I don't know why it can't find the original link_to
  def link_to(text, url)
    "<a href=#{url}>#{text}</a>"
  end

  def link_to_statement(statement)
    link_to(statement, "a/#{replace_spaces(statement)}")
  end

  def readable(text)
    text.gsub("_"," ")
  end

  def replace_spaces(text)
    text.gsub(" ","_")
  end

  def logger
    Dir.mkdir('logs') unless File.exist?('logs')

    $logger = Logger.new('logs/common.log','weekly')
    $logger.level = Logger::WARN

    # Spit stdout and stderr to a file during production
    # in case something goes wrong
    $stdout.reopen("logs/output.log", "w")
    $stdout.sync = true
    $stderr.reopen($stdout)
  end
end

get '/join' do
  haml :join
end

post '/join' do 
  credentials = YAML.load(File.open("credentials.yaml"))
  Horse.contact(
    :name => params[:name],
    :email => params[:email],
    :msg => params[:body])
  redirect '/sent'
end
get '/sent' do
  haml :sent
end

get '/a/:statement' do
  @filter = params[:filter]
  logger
  @statement = Statement.new(params[:statement])
  supporters = @statement.supporters(:filter => @filter)
  detractors = @statement.detractors(:filter => @filter)
  n_opinators = [supporters.size,detractors.size]
  n_arrows = n_opinators.max
  @opinators = []
  n_arrows.times{|i| @opinators << [supporters[i], detractors[i]] }
  haml :statement, :locals => { :n_opinators => n_opinators}
end


get '/a/:statement/new' do
  logger
  haml :new_supporter, :locals => {:statement => params[:statement], :agrees_or_disagrees => params[:disagree] ? "disagrees" : "agrees"}
end

post '/a/:statement/new' do
  o = Opinator.new(params[:name].strip.downcase)
  if params[:disagree] == "true"
    result = o.put_disagreement(params[:statement], params[:source].strip)
  else
    result = o.put_agreement(params[:statement], params[:source].strip)
  end
  if result
    # log
    type = params[:disagree] ? "Detractor" : "Supporter"
    #File.open("logs/fluidinfo.txt","a"){|file| file.puts "new #{type}; #{params[:name]}; #{params[:statement]}; #{params[:source]}; #{request.ip}"}
    File.open("logs/fluidinfo.txt","a") do |file|
      file.puts "new #{type}; #{params[:name]}; #{params[:statement]}; #{params[:source]}; #{request.ip}; #{Time.now}"
    end
  end
  "done; " + link_to("back", "/a/#{params[:statement]}")
end

get '/p/:proxy' do
  # test
  o = Opinator.new(params[:proxy])
  haml :proxy, :locals => {:name => params[:proxy], :statements => o.statements, :supporters => o.supporters }
end

get '/p/:proxy/new' do
  # test
  haml :new_proxy_supporter, :locals => {:proxy => params[:proxy]}
end

post '/p/:proxy/new' do
  o = Opinator.new(params[:name].strip.downcase)
  result=o.put_proxy(params[:proxy], params[:source].strip)
  if result
    File.open("logs/fluidinfo.txt","a"){|file| file.puts "new proxy; #{params[:name]}; #{params[:proxy]}; #{params[:source]}; #{request.ip}"}
  end
  "done; " + link_to("back", "/p/#{params[:proxy]}")
end

