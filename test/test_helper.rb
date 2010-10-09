require 'test/unit'

require 'rubygems'
require 'redgreen'
require 'mocha'

require 'guidebot'
require 'guidebot_app'

def strip_html(string)
  string.gsub(/<\/?[^>]*>/, "")
end