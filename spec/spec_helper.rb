require 'rubygems'
require 'spec'
require 'mocha'
require 'fakeweb'
require 'cgi'

$:.unshift((File.join(File.dirname(__FILE__), '..', 'lib')))
require 'barometer'

FakeWeb.allow_net_connect = false

Barometer.debug!

  #
  # Set random test keys
  #
  KEY = "ABC123"
  Barometer.google_geocode_key = KEY
	WEATHER_PARTNER_KEY = "1234"
	WEATHER_LICENSE_KEY = "12345"
	WEATHERBUG_CODE = "A9999"

  #
  # for geocoding
  #
  geo_url = "http://maps.google.com/maps/geo?"
  FakeWeb.register_uri(:get, 
    "#{geo_url}gl=US&key=#{KEY}&sensor=false&q=90210&output=json",
    :body => File.read(File.join(File.dirname(__FILE__),  
      'fixtures/geocode',
      '90210.json')
    )
  )
  FakeWeb.register_uri(:get, 
    "#{geo_url}gl=&q=#{CGI.escape("40.756054,-73.986951")}&output=json&key=#{KEY}&sensor=false",
    :body => File.read(File.join(File.dirname(__FILE__),  
      'fixtures/geocode',
      '40_73.json')
    )
  )
  
  FakeWeb.register_uri(:get, 
    "#{geo_url}gl=&q=New%20York%2C%20NY&output=json&key=#{KEY}&sensor=false",
    :body => File.read(File.join(File.dirname(__FILE__),  
      'fixtures/geocode',
      'newyork_ny.json')
    )
  )
  FakeWeb.register_uri(:get, 
    "#{geo_url}gl=CA&key=#{KEY}&output=json&q=T5B%204M9&sensor=false",
    :body => File.read(File.join(File.dirname(__FILE__),  
      'fixtures/geocode',
      'T5B4M9.json')
    )
  )
  FakeWeb.register_uri(:get, 
    "#{geo_url}gl=US&q=KSFO&output=json&key=#{KEY}&sensor=false",
    :body => File.read(File.join(File.dirname(__FILE__), 
      'fixtures/geocode',
      'ksfo.json')
    )
  )
  FakeWeb.register_uri(:get, 
    "#{geo_url}gl=&q=Atlanta%2C%20GA%2C%20US&output=json&key=#{KEY}&sensor=false",
    :body => File.read(File.join(File.dirname(__FILE__),  
      'fixtures/geocode',
      'atlanta.json')
    )
  )
  FakeWeb.register_uri(:get, 
    "#{geo_url}output=xml&q=Atlanta%2C%20GA%2C%20US&gl=US&key=#{KEY}",
    :body => File.read(File.join(File.dirname(__FILE__),  
      'fixtures/geocode',
      'atlanta.xml')
    )
  )  
  FakeWeb.register_uri(:get, 
    "#{geo_url}gl=&key=#{KEY}&q=Calgary%2CAB&sensor=false&output=json",
    :body => File.read(File.join(File.dirname(__FILE__), 
      'fixtures/geocode',
      'calgary_ab.json')
    )
  )
  #
  # for weather.com searches
  #
  FakeWeb.register_uri(:get, 
    "http://xoap.weather.com:80/search/search?where=Beverly%20Hills%2C%20CA%2C%20USA",
    :body => File.read(File.join(File.dirname(__FILE__), 
      'fixtures/formats/weather_id', 
      '90210.xml')
    )
  )
  FakeWeb.register_uri(:get, 
    "http://xoap.weather.com:80/search/search?where=New%20York%2C%20NY",
    :body => File.read(File.join(File.dirname(__FILE__), 
      'fixtures/formats/weather_id',
      'new_york.xml')
    )
  )
  FakeWeb.register_uri(:get, 
    "http://xoap.weather.com:80/search/search?where=New%20York%2C%20NY%2C%20USA",
    :body => File.read(File.join(File.dirname(__FILE__), 
      'fixtures/formats/weather_id',
      'new_york.xml')
    )
  )
  FakeWeb.register_uri(:get, 
    "http://xoap.weather.com:80/search/search?where=90210",
    :body => File.read(File.join(File.dirname(__FILE__), 
      'fixtures/formats/weather_id',
      '90210.xml')
    )
  )
  FakeWeb.register_uri(:get, 
    "http://xoap.weather.com:80/search/search?where=Millbrae%2C%20CA%2C%20USA",
    :body => File.read(File.join(File.dirname(__FILE__), 
      'fixtures/formats/weather_id',
      'ksfo.xml')
    )
  )
  #
  # for yahoo.com searches
  #
  FakeWeb.register_uri(:get, 
    "http://weather.yahooapis.com:80/forecastrss?p=USGA0028",
    :body => File.read(File.join(File.dirname(__FILE__), 
      'fixtures/formats/weather_id', 
      'from_USGA0028.xml')
    )
  )
  
  #
  # For wunderground weather
  #
  FakeWeb.register_uri(:get, 
    "http://api.wunderground.com/auto/wui/geo/WXCurrentObXML/index.xml?query=51.055149%2C-114.062438",
    :body => File.read(File.join(File.dirname(__FILE__), 
      'fixtures/services/wunderground',
      'current_calgary_ab.xml')
    )
  )  
  FakeWeb.register_uri(:get, 
    "http://api.wunderground.com/auto/wui/geo/ForecastXML/index.xml?query=51.055149%2C-114.062438",
    :body => File.read(File.join(File.dirname(__FILE__), 
      'fixtures/services/wunderground',
      'forecast_calgary_ab.xml')
    )
  )

Spec::Runner.configure do |config|
  
end
