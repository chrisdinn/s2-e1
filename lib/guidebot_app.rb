require 'sinatra/base'
require 'pony'
require 'logger'

class GuidebotApp < Sinatra::Base
  configure do
    LOGGER = Logger.new("log/production.log") 
  end

  helpers do
    def logger
      LOGGER
    end
  end
  
  post "/request" do
    logger.info params.inspect
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
    logger.info message.inspect
    Pony.mail(message)
    
    "Success"
  end
  
end