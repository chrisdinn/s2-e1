require 'rubygems'
require 'lib/guidebot'
require 'lib/guidebot_app'

log = File.new("log/production.log", "a+")
$stdout.reopen(log)
$stderr.reopen(log)

run GuidebotApp