require 'pony'
require 'yaml'

module Horse
  def self.mail(params)
    Pony.mail(
      :name => params[:name],
      :to => 'hecpeare@gmail.com',
      :subject => params[:subject],
      :body => params[:body],
      :port => '587',
      :via => :smtp,
      :via_options => { 
        :address              => 'smtp.gmail.com', 
        :port                 => '587', 
         :enable_starttls_auto => true, 
        :authentication       => :plain, 
        :domain               => 'localhost.localdomain'
      }.merge( user_name: ENV['Email_user_name'], password: ENV['Email_password']))
  end

  def self.contact(params)
    mail(
      :name => params[:name],
      :subject => "#{params[:name]} has contacted you",
      :body =>"\n
        name: #{params[:name]}\n
        email: #{params[:email]}\n
        msg: #{params[:msg]}")
  end

end
