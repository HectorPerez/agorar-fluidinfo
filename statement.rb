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
