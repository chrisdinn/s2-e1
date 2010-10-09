require 'sinatra/base'
require 'pony'

class GuidebotApp < Sinatra::Base
    
  post "/request" do
    guidebot = Guidebot.new(params[:text])
    message = {
       :to => params[:from],
                  :text => guidebot.directions,
                  :via => :smtp, :via_options => {
                    :address => "smtp.sendgrid.net",
                    :port => "25",
                    :authentication => :plain,
                    :user_name      => env['SENDGRID_USERNAME'],
                    :password       => env['SENDGRID_PASSWORD'],
                    :domain         => env['SENDGRID_DOMAIN']
                  }
    }    
    Pony.mail(message)
    
    "Success"
  end
  
end