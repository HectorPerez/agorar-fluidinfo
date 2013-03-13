class Statement
  attr_accessor :text

  def initialize(text)
    @text = text.gsub(" ", "_")
  end

  def opinators(params = {})
    { :supporters => supporters(params), :detractors => detractors(params) }
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
    m=Fl.new.get(
      "/values",
      :query => "has agreelist.com/#{verb}/#{@text}#{filter}",
      :tags=>["agreelist.com/#{verb}/#{@text}", "fluiddb/about", "en.wikipedia.org/url", "agreelist.com/name"])
    if m.error=="TNonexistentTag"
      []
    else
      a=m.value["results"]["id"]
      supporters=[]
      a.each do |i,j|
        id = j["fluiddb/about"]["value"]
        if j["agreelist.com/name"] and j["agreelist.com/name"]["value"]
          name = j["agreelist.com/name"]["value"]
        else
          name =  id.titleize
        end
        source = j["agreelist.com/#{verb}/#{@text}"]["value"]
        url = j["en.wikipedia.org/url"]
        url = url["value"] if url
        supporters << { :id => id, :name => name, :source => source, :url => url }
      end
      supporters.sort_by{ |i| i[:name] }
    end
  end
  
  def delete!
    supporters.each do |opinator|
      opinator[:id].to_o.no_longer_agrees_that(@text)
    end

    detractors.each do |opinator|
      opinator[:id].to_o.no_longer_disagrees_that(@text)
    end
  end

  def fork(new_name)
    supporters.each do |opinator|
      opinator[:name].downcase.to_o.disagrees_that(new_name, opinator[:source])
    end

    detractors.each do |opinator|
      opinator[:name].downcase.to_o.agrees_that(new_name, opinator[:source])
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
    m=Fl.new.get("values", :query=>"has #{tag('statement')}", :tags=>["fluiddb/about", tag("statement")])
    a=m.value["results"]["id"]
    a.map do |i,j|
        name =  j["fluiddb/about"]["value"]
        updated_at = j[tag("statement")]["updated-at"]
        { :name => name, :updated_at => updated_at}
    end
  end

  def exists?
    c = Fl.new.get("/about/#{text}")
    c.value["tagPaths"].include?("agreelist.com/statement")
  end

  def number_of_opinators
    supporters.size + detractors.size
  end

  private
  def self.tag(name)
    "agreelist.com/#{name}"
  end
end
