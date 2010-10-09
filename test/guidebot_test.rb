require 'test_helper'

class GuidebotTest < Test::Unit::TestCase
  
  def test_parse_request
    origin = "120 Sherbourne St, Toronto, ON"
    destination = "1 Yonge St, Toronto, ON"
    test_request = "directions from #{origin} to #{destination}"
        
    guidebot = Guidebot.new(test_request)
    
    assert_equal origin, guidebot.origin
    assert_equal destination, guidebot.destination
  end
  
  def test_properly_format_api_call
    origin = "120 Sherbourne St, Toronto, ON"
    destination = "1 Yonge St, Toronto, ON"
    test_request = "directions from #{origin} to #{destination}"
    
    api_request = Guidebot::API_URL + "?origin=" + CGI.escape(origin) + "&destination=" + CGI.escape(destination) + "&sensor=false" 
    
    guidebot = Guidebot.new(test_request)
    RestClient.expects(:get).with(api_request).returns(true)
    guidebot.directions
  end
      
end