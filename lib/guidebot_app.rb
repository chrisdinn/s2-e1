require 'sinatra/base'
require 'pony'
require 'logger'

# =GuidebotApp
#
# GuidebotApp is a mailer for Guidebot, built to be deployed using Heroku and the Sendgrid
# Parse API (http://wiki.sendgrid.com/doku.php?id=parse_api)
#
# GuidebotApp uses the Pony gem to send email through the Sendgrid stmp servers 
#
# When deploying, be sure to use the send_grid:free Heroku addon.
#
class GuidebotApp < Sinatra::Base
  configure do
    LOGGER = Logger.new("log/production.log") 
  end

  helpers do
    def logger
      LOGGER
    end
    
    def original_sender_email
      /.* smtp.mail=([A-Z0-9._%-+]+@[A-Z0-9.-]+\.[A-Z]{2,4})/i
    end
    
    def smtp_settings
      { :via => :smtp, :via_options => {
          :address => "smtp.sendgrid.net",
          :port => "25",
          :authentication => :plain,
          :user_name      => ENV['SENDGRID_USERNAME'],
          :password       => ENV['SENDGRID_PASSWORD'],
          :domain         => ENV['SENDGRID_DOMAIN']
        }
      }
    end
  end
  
  post "/request" do
    if params[:headers].match(original_sender_email)
      begin
        guidebot = Guidebot.new(params[:text])
        message = {
            :to => $1,
            :from => "guidebot@digital-achiever.com",
            :subject => "Directions",
            :body => guidebot.directions,
           
        }
      rescue ArgumentError
        message = {
            :to => $1,
            :from => "guidebot@digital-achiever.com",
            :subject => "Directions not found",
            :body => "Received improper request: \"#{params[:text]}\"\n\n" + Guidebot.usage_instructions,
           
        }
      end
      
      logger.info message.inspect
      Pony.mail(message.merge(smtp_settings))
    
      "Success"
    else
      "Failure"
    end
  end
  
end