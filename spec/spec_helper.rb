require 'rubygems'
require 'spec'
require 'fakeweb'
require 'cgi'
require 'yaml'

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'barometer'

FakeWeb.allow_net_connect = false

KEY_FILE = File.expand_path(File.join('~', '.barometer'))

def geocode_google_key_message
  puts
  puts "Please update the key_file '#{KEY_FILE}' with your google api key"
  puts "example:"
  puts "geocode_google: YOUR_KEY_KERE"
  puts
end

if File.exists?(KEY_FILE)
	keys = YAML.load_file(KEY_FILE)
	if keys["geocode_google"]
	  KEY = keys["geocode_google"]
  else
    geocode_google_key_message
    exit
  end
else
  File.open(KEY_FILE, 'w') {|f| f << "geocode_google: YOUR_KEY_KERE" }
  geocode_google_key_message
  exit
end

Spec::Runner.configure do |config|
  
end
