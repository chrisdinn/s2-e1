require 'cgi'
require "rest-client"

# Guidebot is a tool for finding directions.
#
# Guidebot relies on the Google Directions API to work in order to its bot-magic
class Guidebot
  
  API_URL = "http://maps.googleapis.com/maps/api/directions/json"
    
  attr_reader :origin
  attr_reader :destination
  
  def initialize(request)
    if request.match(/directions from (.*) to (.*)/i)
      @origin = $1
      @destination = $2
    else
      raise ArgumentError.new("Invalid request")
    end
  end
  
  def directions
    api_request = API_URL + "?origin=" + CGI.escape(origin) + "&destination=" + CGI.escape(destination) + "&sensor=false"
    api_response = RestClient.get(api_request)
    puts api_response.to_s
  end
  
end