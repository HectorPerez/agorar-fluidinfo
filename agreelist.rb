require 'rubygems'
require 'fluidinfo'
require 'yaml'
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
class Statement
  attr_accessor :statement
  def initialize(statement)
    @statement = statement.gsub(" ", "_")
  end
  def opinators(params = {})
    {:supporters => supporters(params), :detractors => detractors(params)}
  end
  def detractors(params = {})
    supporters(params.merge({:disagree => true}))
  end
  def supporters(params = {})
    verb = params[:disagree] ? "disagree" : "agree"
    if params[:filter].nil? or params[:filter].empty?
      filter = ""
    else
      filters = params[:filter].split(",").map do |i|
        " and has agreelist.com/#{i.strip}"
      end
      filter = filters.join
    end
    m=Fl.new.get("/values", :query => "has agreelist.com/#{verb}/#{@statement}#{filter}", :tags=>["agreelist.com/#{verb}/#{@statement}", "fluiddb/about", "en.wikipedia.org/url"])
    if m.error=="TNonexistentTag"
      []
    else
      a=m.value["results"]["id"]
      supporters=[]
      a.each do |i,j|
        name =  j["fluiddb/about"]["value"].titleize
        source = j["agreelist.com/#{verb}/#{@statement}"]["value"]
        url = j["en.wikipedia.org/url"]
        url = url["value"] if url
        supporters<<{ :name => name, :source => source, :url => url}
      end
      supporters.sort_by{|i| i[:name]}
    end
  end
  def related
    Fl.new.get("/about/#{@statement}/agreelist.com/related").value
  end
  def related=(related_statements)
    response=Fl.new.put("/about/#{@statement}/agreelist.com/related", :body=>related_statements)
    response.error.nil?
  end
  def self.find_names
    m=Fl.new.get("values", :query=>"has agreelist.com/statement", :tags=>"fluiddb/about")
    m.value["results"]["id"].map{|i,j| j["fluiddb/about"]["value"]}
  end
  def self.find
    m=Fl.new.get("values", :query=>"has agreelist.com/statement", :tags=>["fluiddb/about", "agreelist.com/statement"])
    a=m.value["results"]["id"]
    a.map do |i,j|
        name =  j["fluiddb/about"]["value"]
        updated_at = j["agreelist.com/statement"]["updated-at"]
        { :name => name, :updated_at => updated_at}
    end
  end
end

class Opinator
  attr_accessor :name
  def initialize(name)
    @name = name
  end
  def statements
    p=Fl.new.get("/about/#{@name}")
    t=p.value["tagPaths"]
    agrees=[]
    disagrees=[]
    t.each do |s|
      if s.include?("agreelist.com/agree/")
        agrees << Statement.new(s.gsub("agreelist.com/agree/", ""))
      elsif s.include?("agreelist.com/disagree/")
        disagrees << Statement.new(s.gsub("agreelist.com/disagree/", ""))
      end
    end
    {:agrees => agrees, :disagrees => disagrees}
  end
  def agrees
    statements[:agrees]
  end
  def disagrees
    statements[:disagrees]
  end
  def put_agreement(statement, source)
    Fl.new.put("/about/#{statement}/agreelist.com/statement")
    a = Fl.new.put("/about/#{@name}/agreelist.com/agree/#{statement}", :body => source)
    a.error.nil?
  end
  def put_disagreement(statement, source)
    Fl.new.put("/about/#{statement}/agreelist.com/statement")
    a = Fl.new.put("/about/#{@name}/agreelist.com/disagree/#{statement}", :body => source)
    a.error.nil?
  end
  def put_proxy(proxy, source)
    # test
    a = Fl.new.put("/about/#{@name}/agreelist.com/proxy/#{proxy}", :body => source)
    a.error.nil?
  end
  def delete_agreement(statement)
    a=Fl.new.delete("/about/#{@name}/agreelist.com/agree/#{statement}")
    a.error.nil?
  end
  def delete_disagreement(statement)
    a=Fl.new.delete("/about/#{@name}/agreelist.com/disagree/#{statement}")
    a.error.nil?
  end
  def delete_proxy(proxy)
    # test
    a=Fl.new.delete("/about/#{@name}/agreelist.com/proxy/#{proxy}")
    a.error.nil?
  end
  def wikipedia?
    a=Fl.new.get("/about/#{name}")
    a.value["tagPaths"].include?("en.wikipedia.org/url")
  end
  def supporters
    # test
    m=Fl.new.get("/values", :query => "has agreelist.com/proxy/#{@name}", :tags=>["agreelist.com/proxy/#{@name}", "fluiddb/about", "en.wikipedia.org/url"])
    if m.error=="TNonexistentTag"
      []
    else
      a=m.value["results"]["id"]
      supporters=[]
      a.each do |i,j|
        name =  j["fluiddb/about"]["value"].titleize
        source = j["agreelist.com/proxy/#{@name}"]["value"]
        url = j["en.wikipedia.org/url"]
        url = url["value"] if url
        supporters<<{ :name => name, :source => source, :url => url }
      end
      supporters.sort_by{|i| i[:name]}
    end
  end
end
class Supporter < Opinator
end
class Detractor < Opinator
end

class String
  def titleize
    split(/(\W)/).map(&:capitalize).join
  end
end
