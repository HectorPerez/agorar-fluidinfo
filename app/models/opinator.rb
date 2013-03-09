class Opinator
  attr_accessor :name

  def initialize(name)
    @name = name
  end

  def statements
    p = Fl.new.get("/about/#{@name}")
    t = p.value["tagPaths"]
    agrees = []
    disagrees = []
    t.each do |s|
      if s.include?("agreelist.com/agree/")
        agrees << Statement.new(s.gsub("agreelist.com/agree/", ""))
      elsif s.include?("agreelist.com/disagree/")
        disagrees << Statement.new(s.gsub("agreelist.com/disagree/", ""))
      end
    end
    { :agrees => agrees, :disagrees => disagrees }
  end

  def agrees
    statements[:agrees]
  end

  def disagrees
    statements[:disagrees]
  end

  def put_agreement(statement, source)
    set_statement_tag(statement)
    a = Fl.new.put("/about/#{@name}/agreelist.com/agree/#{statement}", :body => source)
    a.error.nil?
  end

  def put_disagreement(statement, source)
    set_statement_tag(statement)
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
    m=Fl.new.get(
      "/values",
      :query => "has agreelist.com/proxy/#{@name}",
      :tags=>[
        "agreelist.com/proxy/#{@name}",
        "fluiddb/about",
        "en.wikipedia.org/url"])
    if m.error == "TNonexistentTag"
      []
    else
      a=m.value["results"]["id"]
      supporters = []
      a.each do |i,j|
        name = j["fluiddb/about"]["value"].titleize
        source = j["agreelist.com/proxy/#{@name}"]["value"]
        url = j["en.wikipedia.org/url"]
        url = url["value"] if url
        supporters << { :name => name, :source => source, :url => url }
      end
      supporters.sort_by{ |i| i[:name] }
    end
  end

  alias agrees_that put_agreement
  alias disagrees_that put_disagreement
  alias no_longer_disagrees_that delete_disagreement
  alias no_longer_agrees_that delete_agreement

  private
  def set_statement_tag(statement)
    Fl.new.put( about_url(statement, "statement") )
  end

  def about_url(object, tag)
    "/about/#{object}/agreelist.com/#{tag}"
  end
end
