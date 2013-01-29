class Statement
  attr_accessor :text

  def initialize(text)
    @text = text.gsub(" ", "_")
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
    m=Fl.new.get("/values", :query => "has agreelist.com/#{verb}/#{@text}#{filter}", :tags=>["agreelist.com/#{verb}/#{@text}", "fluiddb/about", "en.wikipedia.org/url"])
    if m.error=="TNonexistentTag"
      []
    else
      a=m.value["results"]["id"]
      supporters=[]
      a.each do |i,j|
        name =  j["fluiddb/about"]["value"].titleize
        source = j["agreelist.com/#{verb}/#{@text}"]["value"]
        url = j["en.wikipedia.org/url"]
        url = url["value"] if url
        supporters<<{ :name => name, :source => source, :url => url}
      end
      supporters.sort_by{|i| i[:name]}
    end
  end

  def related
    Fl.new.get("/about/#{@text}/agreelist.com/related").value
  end

  def related=(related_statements)
    response=Fl.new.put("/about/#{@text}/agreelist.com/related", :body=>related_statements)
    response.error.nil?
  end

  def self.find_names
    m=Fl.new.get("values", :query=>"has #{tag(statement)}", :tags=>"fluiddb/about")
    m.value["results"]["id"].map{|i,j| j["fluiddb/about"]["value"]}
  end

  def self.find
    m=Fl.new.get("values", :query=>"has #{tag(statement)}", :tags=>["fluiddb/about", tag(statement)])
    a=m.value["results"]["id"]
    a.map do |i,j|
        name =  j["fluiddb/about"]["value"]
        updated_at = j[tag(statement)]["updated-at"]
        { :name => name, :updated_at => updated_at}
    end
  end
  
  private
  def tag(name)
    "agreelist.com/#{name}"
  end
end
