require 'test_helper'
require 'rack/test'

class GuidebotAppTest < Test::Unit::TestCase
  include Rack::Test::Methods  
  
  def app
    GuidebotApp.new
  end
 
  def setup
    Pony.stubs(:mail).returns(true)
  end
 
  def test_valid_request_is_successful
    sendgrid_email_params = { :text => "directions from 120 Sherbourne St, Toronto, ON to 1 Bloor St, Toronto, ON", :headers => "smtp.mail=chris@testemail.com" }
    post '/request', sendgrid_email_params
    assert last_response.ok?
  end
  
  def test_valid_request_should_send_proper_email

    heroku_sendgrid_username = "username"
    heroku_sendgrid_password = "password"
    heroku_sendgrid_domain = "domain"
    
    smtp_settings = { :via => :smtp, :via_options => {
        :address        => 'smtp.sendgrid.net',
        :port           => '25',
        :authentication => :plain,
        :user_name     => heroku_sendgrid_username,
        :password       => heroku_sendgrid_password,
        :domain         => heroku_sendgrid_domain # the HELO domain provided by the client to the server
      }}
   
    email_from = "chris@testemail.com"
    sendgrid_email_params = { :text => "directions from 120 Sherbourne St, Toronto, ON to 1 Bloor St, Toronto, ON", :headers => "...as permitted sender) smtp.mail=#{email_from}; dkim=pass " }
    
    Pony.expects(:mail).with(smtp_settings.merge({  :to => email_from, 
                                                    :from => "guidebot@heroku.com",
                                                    :subject => "Directions",
                                                    :body => Guidebot.new(sendgrid_email_params[:text]).directions
                                                  })).returns(true)
  
    post '/request', sendgrid_email_params, 'SENDGRID_USERNAME' => heroku_sendgrid_username, 'SENDGRID_PASSWORD' => heroku_sendgrid_password, 'SENDGRID_DOMAIN' => heroku_sendgrid_domain  
    assert last_response.ok?
  end
  
end