require 'rubygems'
require 'spec'
require 'mocha'
require 'cgi'

require File.expand_path(File.dirname(__FILE__) + '/fakeweb_helper')

$:.unshift((File.join(File.dirname(__FILE__), '..', 'lib')))
require 'barometer'

#Barometer.debug!
Barometer.google_geocode_key = "ABC123"
Barometer.yahoo_placemaker_app_id = "YAHOO"

Spec::Runner.configure do |config|
  
end
