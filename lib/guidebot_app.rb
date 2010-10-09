require 'sinatra/base'
require 'pony'

class GuidebotApp < Sinatra::Base
    
  post "/request" do
    guidebot = Guidebot.new(params[:text])
    message = {
        :to => params[:from],
        :from => "guidebot@heroku.com",
        :subject => "Directions",
        :body => guidebot.directions,
        :via => :smtp, :via_options => {
          :address => "smtp.sendgrid.net",
          :port => "25",
          :authentication => :plain,
          :user_name      => ENV['SENDGRID_USERNAME'],
          :password       => ENV['SENDGRID_PASSWORD'],
          :domain         => ENV['SENDGRID_DOMAIN']
        }
    }    
    Pony.mail(message)
    
    "Success"
  end
  
end