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

    guidebot = Guidebot.new(test_request)
    
    api_request = Guidebot::API_URL + "?origin=" + CGI.escape(origin) + "&destination=" + CGI.escape(destination) + "&sensor=false"   
    RestClient.expects(:get).with(api_request).returns(File.read("test/api_response.json"))
    
    guidebot.directions
  end 
  
  def test_properly_format_api_call_with_extra_input
    origin = "120 Sherbourne St, Toronto, ON"
    destination = "1 Yonge St, Toronto, ON"
    test_request = "directions from #{origin} to #{destination}\n\n--{{signature}} {{pseudo-inspirational quote}}"

    guidebot = Guidebot.new(test_request)
    
    api_request = Guidebot::API_URL + "?origin=" + CGI.escape(origin) + "&destination=" + CGI.escape(destination) + "&sensor=false"     
    RestClient.expects(:get).with(api_request).returns(File.read("test/api_response.json"))
    
    guidebot.directions
  end
  
  def test_properly_format_directions_response
    origin = "120 Sherbourne St, Toronto, ON"
    destination = "1 Yonge St, Toronto, ON"
    
    raw_api_response = File.read("test/api_response.json")
    api_response = JSON.parse(raw_api_response)
    
    
    first_step, second_step, third_step = api_response["routes"].first["legs"].first["steps"]
  
    directions = "Driving directions from #{origin} to #{destination}\n\n"  
    directions << " 1. #{strip_html(first_step["html_instructions"])} - #{first_step["duration"]["text"]}\n\n"
    directions << " 2. #{strip_html(second_step["html_instructions"])} - #{second_step["duration"]["text"]}\n\n"
    directions << " 3. #{strip_html(third_step["html_instructions"])} - #{third_step["duration"]["text"]}\n\n"
    directions << "--\nMap data (c)2010 Google\n\nGuidebot is operated by Chris Dinn <chrisgdinn@gmail.com>"
    
    RestClient.stubs(:get).returns(raw_api_response)
    
    test_request = "directions from #{origin} to #{destination}"
    guidebot = Guidebot.new(test_request)
    
    assert_equal directions, guidebot.directions
  end
  
end