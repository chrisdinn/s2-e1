require 'test_helper'
require 'rack/test'

class GuidebotAppTest < Test::Unit::TestCase
  include Rack::Test::Methods  

  GuidebotApp.const_set("ENV", { 'SENDGRID_USERNAME' => "username", 'SENDGRID_PASSWORD' => "password", 'SENDGRID_DOMAIN' => "domain" })
  
  def app
    GuidebotApp.new
  end
 
  def setup
    Pony.stubs(:mail).returns(true)
    @smtp_settings = { :via => :smtp, :via_options => {
        :address        => 'smtp.sendgrid.net',
        :port           => '25',
        :authentication => :plain,
        :user_name     => GuidebotApp::ENV['SENDGRID_USERNAME'],
        :password       => GuidebotApp::ENV['SENDGRID_PASSWORD'],
        :domain         => GuidebotApp::ENV['SENDGRID_DOMAIN']
      }}
  end
 
  def test_valid_request_in_text_is_successful
    sendgrid_email_params = { :subject => "", :text => "directions from 120 Sherbourne St, Toronto, ON to 1 Bloor St, Toronto, ON", :headers => " smtp.mail=chris@testemail.com" }
    post '/request', sendgrid_email_params
    assert_equal "Success", last_response.body
  end
  
  def test_valid_request_in_subject_is_successful
    sendgrid_email_params = { :subject => "directions from 120 Sherbourne St, Toronto, ON to 1 Bloor St, Toronto, ON", :headers => " smtp.mail=chris@testemail.com" }
    post '/request', sendgrid_email_params
    assert_equal "Success", last_response.body
  end
  
  def test_valid_request_should_send_proper_email
    email_from = "chris@testemail.com"
    sendgrid_email_params = { :text => "directions from 120 Sherbourne St, Toronto, ON to 1 Bloor St, Toronto, ON", :headers => "...as permitted sender) smtp.mail=#{email_from}; dkim=pass " }
    
    Pony.expects(:mail).with(@smtp_settings.merge({ :to => email_from, 
                                                    :from => "guidebot@digital-achiever.com",
                                                    :subject => "Directions",
                                                    :body => Guidebot.new(sendgrid_email_params[:text]).directions
                                                  })).returns(true)
  
    post '/request', sendgrid_email_params
    assert_equal "Success", last_response.body
  end
  
  def test_invalid_request_should_respond_with_usage_instructions
    email_from = "chris@testemail.com"
    sendgrid_email_params = { :text => "bad directions request", :headers => "...as permitted sender) smtp.mail=#{email_from}; dkim=pass " }
    Pony.expects(:mail).with(@smtp_settings.merge({ :to => email_from, 
                                                    :from => "guidebot@digital-achiever.com",
                                                    :subject => "Directions not found",
                                                    :body => "Received improper request: \"#{sendgrid_email_params[:text]}\"\n\nProper usage: directions from {origin} to {destination}, ie. directions from New York, NY to San Francisco, CA"
                                                  })).returns(true)
  
    post '/request', sendgrid_email_params
    assert_equal "Directions not found", last_response.body
  end
  
  
end