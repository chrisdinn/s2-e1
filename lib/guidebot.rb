require 'cgi'
require "rest-client"
require 'json'

# Guidebot is a tool for finding directions.
#
# Guidebot relies on the Google Directions API to work in order to its bot-magic
#
# Guidebot lives at guidebot@digital-achiever.com. To get directions, email 
# with your request in the subject or body.
#
# Ask for directions like this: 
#     directions from Toronto, ON to Miami, FL
class Guidebot
  
  API_URL = "http://maps.googleapis.com/maps/api/directions/json"
    
  def self.usage_instructions
    "Proper usage: directions from {origin} to {destination}, ie. directions from New York, NY to San Francisco, CA"
  end  
    
  attr_reader :origin
  attr_reader :destination
  
  def initialize(request)
    if request.match(/directions from (.*) to (.*)\n*/i)
      @origin = $1
      @destination = $2
    else
      raise ArgumentError.new("Invalid request")
    end
  end
  
  def directions
    api_request = API_URL + "?origin=" + CGI.escape(origin) + "&destination=" + CGI.escape(destination) + "&sensor=false"
    raw_api_response = RestClient.get(api_request)
    directions = JSON.parse(raw_api_response)
    
    response = "Driving directions from #{origin} to #{destination}\n\n"
    
    list_number = 1
    directions["routes"].first["legs"].first["steps"].each do |step|
      response << " #{list_number}. #{strip_html(step["html_instructions"])} - #{step["duration"]["text"]}\n\n"
      list_number += 1
    end
    
    response << "--\nMap data (c)2010 Google\n\nGuidebot is operated by Chris Dinn <chrisgdinn@gmail.com>"
    
    response
  end
  
  private
  
  def strip_html(string)
    string.gsub(/<div [^>]*>/, " ** ").gsub(/<\/?[^>]*>/, "")
  end
  
end