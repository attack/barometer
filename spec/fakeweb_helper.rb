require 'fakeweb'
FakeWeb.allow_net_connect = false

#
# Set random test keys
#
KEY = "ABC123"
WEATHER_PARTNER_KEY = "1234"
WEATHER_LICENSE_KEY = "12345"
WEATHERBUG_CODE = "A9999"
YAHOO_KEY = "YAHOO"

# runcoderun uses a older version of fakeweb that has different syntax
if ENV["RUN_CODE_RUN"]
  
  #
  # for geocoding
  #
  geo_url = "http://maps.google.com/maps/geo?"
  FakeWeb.register_uri(:get, 
    "#{geo_url}gl=US&key=#{KEY}&sensor=false&q=90210&output=json",
    :string => File.read(File.dirname(__FILE__) + '/fixtures/geocode/90210.json')
  )
  
  FakeWeb.register_uri(:get, 
    "#{geo_url}gl=&q=#{CGI.escape("40.756054,-73.986951")}&output=json&key=#{KEY}&sensor=false",
    :string => File.read(File.dirname(__FILE__) + '/fixtures/geocode/40_73.json')
  )
  
  FakeWeb.register_uri(:get, 
    "#{geo_url}gl=&q=New%20York%2C%20NY&output=json&key=#{KEY}&sensor=false",
    :string => File.read(File.dirname(__FILE__) + '/fixtures/geocode/newyork_ny.json')
  )
  FakeWeb.register_uri(:get, 
    "#{geo_url}gl=CA&key=#{KEY}&output=json&q=T5B%204M9&sensor=false",
    :string => File.read(File.dirname(__FILE__) + '/fixtures/geocode/T5B4M9.json')
  )
  FakeWeb.register_uri(:get, 
    "#{geo_url}gl=US&q=KSFO&output=json&key=#{KEY}&sensor=false",
    :string => File.read(File.dirname(__FILE__) + '/fixtures/geocode/ksfo.json')
  )
  FakeWeb.register_uri(:get, 
    "#{geo_url}gl=&q=Atlanta%2C%20GA%2C%20US&output=json&key=#{KEY}&sensor=false",
    :string => File.read(File.dirname(__FILE__) + '/fixtures/geocode/atlanta.json')
  )
  FakeWeb.register_uri(:get, 
    "#{geo_url}output=xml&q=Atlanta%2C%20GA%2C%20US&gl=US&key=#{KEY}",
    :string => File.read(File.dirname(__FILE__) + '/fixtures/geocode/atlanta.xml')
  )  
  FakeWeb.register_uri(:get, 
    "#{geo_url}gl=&key=#{KEY}&q=Calgary%2CAB&sensor=false&output=json",
    :string => File.read(File.dirname(__FILE__) + '/fixtures/geocode/calgary_ab.json')
  )
  #
  # for weather.com searches
  #
  FakeWeb.register_uri(:get, 
    "http://xoap.weather.com:80/search/search?where=Beverly%20Hills%2C%20CA%2C%20USA",
    :string => File.read(File.dirname(__FILE__) + '/fixtures/formats/weather_id/90210.xml')
  )
  FakeWeb.register_uri(:get, 
    "http://xoap.weather.com:80/search/search?where=New%20York%2C%20NY",
    :string => File.read(File.dirname(__FILE__) + '/fixtures/formats/weather_id/new_york.xml')
  )
  FakeWeb.register_uri(:get, 
    "http://xoap.weather.com:80/search/search?where=New%20York%2C%20NY%2C%20USA",
    :string => File.read(File.dirname(__FILE__) + '/fixtures/formats/weather_id/new_york.xml')
  )
  FakeWeb.register_uri(:get, 
    "http://xoap.weather.com:80/search/search?where=90210",
    :string => File.read(File.dirname(__FILE__) + '/fixtures/formats/weather_id/90210.xml')
  )
  FakeWeb.register_uri(:get, 
    "http://xoap.weather.com:80/search/search?where=Millbrae%2C%20CA%2C%20USA",
    :string => File.read(File.dirname(__FILE__) + '/fixtures/formats/weather_id/ksfo.xml')
  )
  #
  # for yahoo.com searches
  #
  FakeWeb.register_uri(:get, 
    "http://weather.yahooapis.com:80/forecastrss?p=USGA0028",
    :string => File.read(File.dirname(__FILE__) + '/fixtures/formats/weather_id/from_USGA0028.xml')
  )
  #
  # for Google weather
  #
  FakeWeb.register_uri(:get, 
    "http://google.com/ig/api?weather=#{CGI.escape('Calgary,AB')}&hl=en-GB",
    :string => File.read(File.dirname(__FILE__) + '/fixtures/services/google/calgary_ab.xml')
  )
  #
  # for WeatherBug weather
  #
  bug_url_current = "http://#{WEATHERBUG_CODE}.api.wxbug.net:80/getLiveWeatherRSS.aspx?"
  FakeWeb.register_uri(:get, 
    "#{bug_url_current}ACode=#{WEATHERBUG_CODE}&OutputType=1&UnitType=1&zipCode=90210",
    :string => File.read(File.dirname(__FILE__) + '/fixtures/services/weather_bug/90210_current.xml')
  )
  bug_url_future = "http://#{WEATHERBUG_CODE}.api.wxbug.net:80/getForecastRSS.aspx?"
  FakeWeb.register_uri(:get, 
    "#{bug_url_future}ACode=#{WEATHERBUG_CODE}&OutputType=1&UnitType=1&zipCode=90210",
    :string => File.read(File.dirname(__FILE__) + '/fixtures/services/weather_bug/90210_forecast.xml')
  )
  #
  # for weather.com weather
  #
  weather_com_url = "http://xoap.weather.com:80/weather/local/"
  FakeWeb.register_uri(:get, 
    "#{weather_com_url}90210?dayf=5&unit=m&link=xoap&par=#{WEATHER_PARTNER_KEY}&prod=xoap&key=#{WEATHER_LICENSE_KEY}&cc=*",
    :string => File.read(File.dirname(__FILE__) + '/fixtures/services/weather_dot_com/90210.xml')
  )
  #
  # for yahoo weather
  #
  FakeWeb.register_uri(:get, 
    "http://weather.yahooapis.com:80/forecastrss?u=c&p=90210",
    :string => File.read(File.dirname(__FILE__) + '/fixtures/services/yahoo/90210.xml')
  )
  
  #
  # For wunderground weather
  #
  FakeWeb.register_uri(:get, 
    "http://api.wunderground.com/auto/wui/geo/WXCurrentObXML/index.xml?query=51.055149%2C-114.062438",
    :string => File.read(File.dirname(__FILE__) + '/fixtures/services/wunderground/current_calgary_ab.xml')
  )  
  FakeWeb.register_uri(:get, 
    "http://api.wunderground.com/auto/wui/geo/ForecastXML/index.xml?query=51.055149%2C-114.062438",
    :string => File.read(File.dirname(__FILE__) + '/fixtures/services/wunderground/forecast_calgary_ab.xml')
  )
  FakeWeb.register_uri(:get, 
    "http://api.wunderground.com/auto/wui/geo/WXCurrentObXML/index.xml?query=#{CGI.escape('Calgary,AB')}",
    :string => File.read(File.dirname(__FILE__) + '/fixtures/services/wunderground/current_calgary_ab.xml')
  )
  FakeWeb.register_uri(:get, 
    "http://api.wunderground.com/auto/wui/geo/ForecastXML/index.xml?query=#{CGI.escape('Calgary,AB')}",
    :string => File.read(File.dirname(__FILE__) + '/fixtures/services/wunderground/forecast_calgary_ab.xml')
  )
  
  #
  # For Placemaker
  #
  FakeWeb.register_uri(:post, 
    "http://wherein.yahooapis.com/v1/document",
    [
      {:string => File.read(File.dirname(__FILE__) + '/fixtures/services/placemaker/the_hills.xml')},
      {:string => File.read(File.dirname(__FILE__) + '/fixtures/services/placemaker/the_hills.xml')},
      {:string => File.read(File.dirname(__FILE__) + '/fixtures/services/placemaker/the_hills.xml')},
      {:string => File.read(File.dirname(__FILE__) + '/fixtures/services/placemaker/the_hills.xml')},
      {:string => File.read(File.dirname(__FILE__) + '/fixtures/services/placemaker/T5B4M9.xml')},  
      {:string => File.read(File.dirname(__FILE__) + '/fixtures/services/placemaker/coords.xml')},
      {:string => File.read(File.dirname(__FILE__) + '/fixtures/services/placemaker/new_york.xml')},
      {:string => File.read(File.dirname(__FILE__) + '/fixtures/services/placemaker/atlanta.xml')},
      {:string => File.read(File.dirname(__FILE__) + '/fixtures/services/placemaker/ksfo.xml')}
    ]
  )
  FakeWeb.register_uri(:get, 
    "http://weather.yahooapis.com/forecastrss?w=615702",
    :string => File.read(File.dirname(__FILE__) + '/fixtures/services/placemaker/w615702.xml')
  )
  
else
  
  #
  # for geocoding
  #
  geo_url = "http://maps.google.com/maps/geo?"
  FakeWeb.register_uri(:get, 
    "#{geo_url}gl=US&key=#{KEY}&sensor=false&q=90210&output=json",
    :body => File.read(File.dirname(__FILE__) + '/fixtures/geocode/90210.json')
  )
  
  FakeWeb.register_uri(:get, 
    "#{geo_url}gl=&q=#{CGI.escape("40.756054,-73.986951")}&output=json&key=#{KEY}&sensor=false",
    :body => File.read(File.dirname(__FILE__) + '/fixtures/geocode/40_73.json')
  )
  
  FakeWeb.register_uri(:get, 
    "#{geo_url}gl=&q=New%20York%2C%20NY&output=json&key=#{KEY}&sensor=false",
    :body => File.read(File.dirname(__FILE__) + '/fixtures/geocode/newyork_ny.json')
  )
  FakeWeb.register_uri(:get, 
    "#{geo_url}gl=CA&key=#{KEY}&output=json&q=T5B%204M9&sensor=false",
    :body => File.read(File.dirname(__FILE__) + '/fixtures/geocode/T5B4M9.json')
  )
  FakeWeb.register_uri(:get, 
    "#{geo_url}gl=US&q=KSFO&output=json&key=#{KEY}&sensor=false",
    :body => File.read(File.dirname(__FILE__) + '/fixtures/geocode/ksfo.json')
  )
  FakeWeb.register_uri(:get, 
    "#{geo_url}gl=&q=Atlanta%2C%20GA%2C%20US&output=json&key=#{KEY}&sensor=false",
    :body => File.read(File.dirname(__FILE__) + '/fixtures/geocode/atlanta.json')
  )
  FakeWeb.register_uri(:get, 
    "#{geo_url}output=xml&q=Atlanta%2C%20GA%2C%20US&gl=US&key=#{KEY}",
    :body => File.read(File.dirname(__FILE__) + '/fixtures/geocode/atlanta.xml')
  )  
  FakeWeb.register_uri(:get, 
    "#{geo_url}gl=&key=#{KEY}&q=Calgary%2CAB&sensor=false&output=json",
    :body => File.read(File.dirname(__FILE__) + '/fixtures/geocode/calgary_ab.json')
  )
  #
  # for weather.com searches
  #
  FakeWeb.register_uri(:get, 
    "http://xoap.weather.com:80/search/search?where=Beverly%20Hills%2C%20CA%2C%20USA",
    :body => File.read(File.dirname(__FILE__) + '/fixtures/formats/weather_id/90210.xml')
  )
  FakeWeb.register_uri(:get, 
    "http://xoap.weather.com:80/search/search?where=New%20York%2C%20NY",
    :body => File.read(File.dirname(__FILE__) + '/fixtures/formats/weather_id/new_york.xml')
  )
  FakeWeb.register_uri(:get, 
    "http://xoap.weather.com:80/search/search?where=New%20York%2C%20NY%2C%20USA",
    :body => File.read(File.dirname(__FILE__) + '/fixtures/formats/weather_id/new_york.xml')
  )
  FakeWeb.register_uri(:get, 
    "http://xoap.weather.com:80/search/search?where=90210",
    :body => File.read(File.dirname(__FILE__) + '/fixtures/formats/weather_id/90210.xml')
  )
  FakeWeb.register_uri(:get, 
    "http://xoap.weather.com:80/search/search?where=Millbrae%2C%20CA%2C%20USA",
    :body => File.read(File.dirname(__FILE__) + '/fixtures/formats/weather_id/ksfo.xml')
  )
  #
  # for yahoo.com searches
  #
  FakeWeb.register_uri(:get, 
    "http://weather.yahooapis.com:80/forecastrss?p=USGA0028",
    :body => File.read(File.dirname(__FILE__) + '/fixtures/formats/weather_id/from_USGA0028.xml')
  )
  #
  # for Google weather
  #
  FakeWeb.register_uri(:get, 
    "http://google.com/ig/api?weather=#{CGI.escape('Calgary,AB')}&hl=en-GB",
    :body => File.read(File.dirname(__FILE__) + '/fixtures/services/google/calgary_ab.xml')
  )
  #
  # for WeatherBug weather
  #
  bug_url_current = "http://#{WEATHERBUG_CODE}.api.wxbug.net:80/getLiveWeatherRSS.aspx?"
  FakeWeb.register_uri(:get, 
    "#{bug_url_current}ACode=#{WEATHERBUG_CODE}&OutputType=1&UnitType=1&zipCode=90210",
    :body => File.read(File.dirname(__FILE__) + '/fixtures/services/weather_bug/90210_current.xml')
  )
  
  bug_url_future = "http://#{WEATHERBUG_CODE}.api.wxbug.net:80/getForecastRSS.aspx?"
  FakeWeb.register_uri(:get, 
    "#{bug_url_future}ACode=#{WEATHERBUG_CODE}&OutputType=1&UnitType=1&zipCode=90210",
    :body => File.read(File.dirname(__FILE__) + '/fixtures/services/weather_bug/90210_forecast.xml')
  )
  #
  # for weather.com weather
  #
  weather_com_url = "http://xoap.weather.com:80/weather/local/"
  FakeWeb.register_uri(:get, 
    "#{weather_com_url}90210?dayf=5&unit=m&link=xoap&par=#{WEATHER_PARTNER_KEY}&prod=xoap&key=#{WEATHER_LICENSE_KEY}&cc=*",
    :body => File.read(File.dirname(__FILE__) + '/fixtures/services/weather_dot_com/90210.xml')
  )
  #
  # for yahoo weather
  #
  FakeWeb.register_uri(:get, 
    "http://weather.yahooapis.com:80/forecastrss?u=c&p=90210",
    :body => File.read(File.dirname(__FILE__) + '/fixtures/services/yahoo/90210.xml')
  )
  
  #
  # For wunderground weather
  #
  FakeWeb.register_uri(:get, 
    "http://api.wunderground.com/auto/wui/geo/WXCurrentObXML/index.xml?query=51.055149%2C-114.062438",
    :body => File.read(File.dirname(__FILE__) + '/fixtures/services/wunderground/current_calgary_ab.xml')
  )  
  FakeWeb.register_uri(:get, 
    "http://api.wunderground.com/auto/wui/geo/ForecastXML/index.xml?query=51.055149%2C-114.062438",
    :body => File.read(File.dirname(__FILE__) + '/fixtures/services/wunderground/forecast_calgary_ab.xml')
  )  
  FakeWeb.register_uri(:get, 
    "http://api.wunderground.com/auto/wui/geo/WXCurrentObXML/index.xml?query=#{CGI.escape('Calgary,AB')}",
    :body => File.read(File.dirname(__FILE__) + '/fixtures/services/wunderground/current_calgary_ab.xml')
  )
  FakeWeb.register_uri(:get, 
    "http://api.wunderground.com/auto/wui/geo/ForecastXML/index.xml?query=#{CGI.escape('Calgary,AB')}",
    :body => File.read(File.dirname(__FILE__) + '/fixtures/services/wunderground/forecast_calgary_ab.xml')
  )
  
  #
  # For Placemaker
  #
  FakeWeb.register_uri(:post, 
    "http://wherein.yahooapis.com/v1/document",
    [
      {:body => File.read(File.dirname(__FILE__) + '/fixtures/services/placemaker/the_hills.xml')},
      {:body => File.read(File.dirname(__FILE__) + '/fixtures/services/placemaker/the_hills.xml')},
      {:body => File.read(File.dirname(__FILE__) + '/fixtures/services/placemaker/the_hills.xml')},
      {:body => File.read(File.dirname(__FILE__) + '/fixtures/services/placemaker/T5B4M9.xml')},  
      {:body => File.read(File.dirname(__FILE__) + '/fixtures/services/placemaker/coords.xml')},
      {:body => File.read(File.dirname(__FILE__) + '/fixtures/services/placemaker/new_york.xml')},
      {:body => File.read(File.dirname(__FILE__) + '/fixtures/services/placemaker/atlanta.xml')},
      {:body => File.read(File.dirname(__FILE__) + '/fixtures/services/placemaker/ksfo.xml')}
    ]
  )

  FakeWeb.register_uri(:get, 
    "http://weather.yahooapis.com/forecastrss?w=615702",
    :body => File.read(File.dirname(__FILE__) + '/fixtures/services/placemaker/w615702.xml')
  )
  
end