require 'test/unit'

require 'rubygems'
require 'redgreen'
require 'mocha'

require 'guidebot'

def strip_html(string)
  string.gsub(/<\/?[^>]*>/, "")
end