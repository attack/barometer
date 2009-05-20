require 'rubygems'
require 'spec'
require 'mocha'
require 'fakeweb'
require 'cgi'
require 'yaml'

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'lib/barometer'

FakeWeb.allow_net_connect = false

KEY_FILE = File.expand_path(File.join('~', '.barometer'))

def geocode_google_key_message
  puts
  puts "Please update the key_file '#{KEY_FILE}' with your google api key"
  puts "example:"
  puts "google: geocode: YOUR_KEY_KERE"
  puts
end

if File.exists?(KEY_FILE)
	keys = YAML.load_file(KEY_FILE)
	if keys["google"]
	  KEY = keys["google"]["geocode"]
  else
    geocode_google_key_message
    exit
  end
  if keys["weather"]
  	WEATHER_PARTNER_KEY = keys["weather"]["partner"]
  	WEATHER_LICENSE_KEY = keys["weather"]["license"]
	end
  if keys["weather_bug"]
  	WEATHERBUG_CODE = keys["weather_bug"]["code"]
	end
    
else
  File.open(KEY_FILE, 'w') {|f| f << "google: geocode: YOUR_KEY_KERE" }
  geocode_google_key_message
  exit
end

  #
  # for geocoding
  #
  geo_url = "http://maps.google.com/maps/geo?"
  FakeWeb.register_uri(:get, 
    "#{geo_url}gl=US&q=90210&output=xml&key=#{KEY}",
    :string => File.read(File.join(File.dirname(__FILE__),  
      'fixtures/geocode',
      '90210.xml')
    )
  )
  FakeWeb.register_uri(:get, 
    "#{geo_url}gl=&q=#{CGI.escape("40.756054,-73.986951")}&output=xml&key=#{KEY}",
    :string => File.read(File.join(File.dirname(__FILE__),  
      'fixtures/geocode',
      '40_73.xml')
    )
  )
  
  # FakeWeb.register_uri(:get, 
  #   "#{geo_url}gl=&q=90210&output=xml&key=#{KEY}",
  #   :string => File.read(File.join(File.dirname(__FILE__),  
  #     'fixtures/geocode',
  #     '90210.xml')
  #   )
  # )
  FakeWeb.register_uri(:get, 
    "#{geo_url}gl=&q=New%20York%2C%20NY&output=xml&key=#{KEY}",
    :string => File.read(File.join(File.dirname(__FILE__),  
      'fixtures/geocode',
      'newyork_ny.xml')
    )
  )
  FakeWeb.register_uri(:get, 
    "#{geo_url}gl=CA&key=#{@key}&output=xml&q=T5B%204M9",
    :string => File.read(File.join(File.dirname(__FILE__),  
      'fixtures/geocode',
      'T5B4M9.xml')
    )
  )
  
  FakeWeb.register_uri(:get, 
    "#{geo_url}gl=&q=T5B%204M9&output=xml&key=#{KEY}",
    :string => File.read(File.join(File.dirname(__FILE__), 
      'fixtures/geocode',
      'T5B4M9.xml')
    )
  )  
  FakeWeb.register_uri(:get, 
    "#{geo_url}output=xml&q=T5B%204M9&gl=CA&key=#{KEY}",
    :string => File.read(File.join(File.dirname(__FILE__), 
      'fixtures/geocode',
      'T5B4M9.xml')
    )
  )
  FakeWeb.register_uri(:get, 
    "#{geo_url}gl=US&q=KSFO&output=xml&key=#{KEY}",
    :string => File.read(File.join(File.dirname(__FILE__), 
      'fixtures/geocode',
      'ksfo.xml')
    )
  )
  FakeWeb.register_uri(:get, 
    "#{geo_url}gl=&q=Atlanta%2C%20GA%2C%20US&output=xml&key=#{KEY}",
    :string => File.read(File.join(File.dirname(__FILE__),  
      'fixtures/geocode',
      'atlanta.xml')
    )
  )
  FakeWeb.register_uri(:get, 
    "#{geo_url}output=xml&q=Atlanta%2C%20GA%2C%20US&gl=US&key=#{KEY}",
    :string => File.read(File.join(File.dirname(__FILE__),  
      'fixtures/geocode',
      'atlanta.xml')
    )
  )
  #
  # for weather.com searches
  #
  FakeWeb.register_uri(:get, 
    "http://xoap.weather.com:80/search/search?where=Beverly%20Hills%2C%20CA%2C%20USA",
    :string => File.read(File.join(File.dirname(__FILE__), 
      'fixtures/formats/weather_id', 
      '90210.xml')
    )
  )
  FakeWeb.register_uri(:get, 
    "http://xoap.weather.com:80/search/search?where=New%20York%2C%20NY",
    :string => File.read(File.join(File.dirname(__FILE__), 
      'fixtures/formats/weather_id',
      'new_york.xml')
    )
  )
  FakeWeb.register_uri(:get, 
    "http://xoap.weather.com:80/search/search?where=New%20York%2C%20NY%2C%20USA",
    :string => File.read(File.join(File.dirname(__FILE__), 
      'fixtures/formats/weather_id',
      'new_york.xml')
    )
  )
  FakeWeb.register_uri(:get, 
    "http://xoap.weather.com:80/search/search?where=90210",
    :string => File.read(File.join(File.dirname(__FILE__), 
      'fixtures/formats/weather_id',
      '90210.xml')
    )
  )
  FakeWeb.register_uri(:get, 
    "http://xoap.weather.com:80/search/search?where=San%20Francisco%20%2C%20USA",
    :string => File.read(File.join(File.dirname(__FILE__), 
      'fixtures/formats/weather_id',
      'ksfo.xml')
    )
  )
  #
  # for yahoo.com searches
  #
  FakeWeb.register_uri(:get, 
    "http://weather.yahooapis.com:80/forecastrss?p=USGA0028",
    :string => File.read(File.join(File.dirname(__FILE__), 
      'fixtures/formats/weather_id', 
      'from_USGA0028.xml')
    )
  )
  
  #
  # For wunderground weather
  #
  FakeWeb.register_uri(:get, 
    "http://api.wunderground.com/auto/wui/geo/WXCurrentObXML/index.xml?query=51.055149%2C-114.062438",
    :string => File.read(File.join(File.dirname(__FILE__), 
      'fixtures/services/wunderground',
      'current_calgary_ab.xml')
    )
  )  
  FakeWeb.register_uri(:get, 
    "http://api.wunderground.com/auto/wui/geo/ForecastXML/index.xml?query=51.055149%2C-114.062438",
    :string => File.read(File.join(File.dirname(__FILE__), 
      'fixtures/services/wunderground',
      'forecast_calgary_ab.xml')
    )
  )

Spec::Runner.configure do |config|
  
end
