require 'fakeweb'
FakeWeb.allow_net_connect = false

#
# Set random test keys
#
WEATHER_PARTNER_KEY = "1234"
WEATHER_LICENSE_KEY = "12345"
WEATHERBUG_CODE = "A9999"
YAHOO_KEY = "YAHOO"

#
# for geocoding
#
geo_url_v3 = "http://maps.googleapis.com/maps/api/geocode/json?"

# http://maps.googleapis.com/maps/api/geocode/json?region=US&sensor=false&address=90210
FakeWeb.register_uri(:get, 
  "#{geo_url_v3}region=US&sensor=false&address=90210",
  :body => File.read(File.dirname(__FILE__) + '/fixtures/geocode/90210_v3.json')
)
# http://maps.googleapis.com/maps/api/geocode/json?region=&sensor=false&latlng=40.756054%2C-73.986951
FakeWeb.register_uri(:get, 
  "#{geo_url_v3}region=&sensor=false&latlng=40.756054%2C-73.986951",
  :body => File.read(File.dirname(__FILE__) + '/fixtures/geocode/40_73_v3.json')
)
# http://maps.googleapis.com/maps/api/geocode/json?region=&sensor=false&address=New%20York%2C%20NY
FakeWeb.register_uri(:get, 
  "#{geo_url_v3}region=&sensor=false&address=New%20York%2C%20NY",
  :body => File.read(File.dirname(__FILE__) + '/fixtures/geocode/newyork_ny_v3.json')
)
# http://maps.googleapis.com/maps/api/geocode/json?region=CA&sensor=false&address=T5B%204M9
FakeWeb.register_uri(:get, 
  "#{geo_url_v3}region=CA&sensor=false&address=T5B%204M9",
  :body => File.read(File.dirname(__FILE__) + '/fixtures/geocode/T5B4M9_v3.json')
)
# http://maps.googleapis.com/maps/api/geocode/json?region=US&sensor=false&address=KSFO
FakeWeb.register_uri(:get, 
  "#{geo_url_v3}region=US&sensor=false&address=KSFO",
  :body => File.read(File.dirname(__FILE__) + '/fixtures/geocode/ksfo_v3.json')
)
# http://maps.googleapis.com/maps/api/geocode/json?region=&sensor=false&address=Atlanta%2C%20GA%2C%20US
FakeWeb.register_uri(:get, 
  "#{geo_url_v3}region=&sensor=false&address=Atlanta%2C%20GA%2C%20US",
  :body => File.read(File.dirname(__FILE__) + '/fixtures/geocode/atlanta_v3.json')
)
# http://maps.googleapis.com/maps/api/geocode/json?region=&sensor=false&address=Calgary%2CAB
FakeWeb.register_uri(:get, 
  "#{geo_url_v3}region=&sensor=false&address=Calgary%2CAB",
  :body => File.read(File.dirname(__FILE__) + '/fixtures/geocode/calgary_ab_v3.json')
)
#
# for weather.com searches
#
# http://xoap.weather.com:80/search/search?where=Beverly%20Hills%2C%20CA%2C%20USA
FakeWeb.register_uri(:get, 
  "http://xoap.weather.com:80/search/search?where=Beverly%20Hills%2C%20CA%2C%20United%20States",
  :body => File.read(File.dirname(__FILE__) + '/fixtures/formats/weather_id/the_hills.xml')
)
# http://xoap.weather.com:80/search/search?where=New%20York%2C%20NY
FakeWeb.register_uri(:get, 
  "http://xoap.weather.com:80/search/search?where=New%20York%2C%20NY",
  :body => File.read(File.dirname(__FILE__) + '/fixtures/formats/weather_id/new_york.xml')
)
# http://xoap.weather.com:80/search/search?where=Manhattan%2C%20NY%2C%20USA
FakeWeb.register_uri(:get, 
  "http://xoap.weather.com:80/search/search?where=Manhattan%2C%20NY%2C%20United%20States",
  :body => File.read(File.dirname(__FILE__) + '/fixtures/formats/weather_id/manhattan.xml')
)
# http://xoap.weather.com:80/search/search?where=New%20York%2C%20NY%2C%20USA
FakeWeb.register_uri(:get, 
  "http://xoap.weather.com:80/search/search?where=New%20York%2C%20NY%2C%20United%20States",
  :body => File.read(File.dirname(__FILE__) + '/fixtures/formats/weather_id/new_york.xml')
)
# http://xoap.weather.com:80/search/search?where=90210
FakeWeb.register_uri(:get, 
  "http://xoap.weather.com:80/search/search?where=90210",
  :body => File.read(File.dirname(__FILE__) + '/fixtures/formats/weather_id/90210.xml')
)
# http://xoap.weather.com:80/search/search?where=San%20Francisco%2C%20CA%2C%20USA
FakeWeb.register_uri(:get, 
  "http://xoap.weather.com:80/search/search?where=San%20Francisco%2C%20CA%2C%20United%20States",
  :body => File.read(File.dirname(__FILE__) + '/fixtures/formats/weather_id/ksfo.xml')
)
#
# for yahoo.com searches
#
# http://weather.yahooapis.com:80/forecastrss?p=USGA0028
FakeWeb.register_uri(:get, 
  "http://weather.yahooapis.com:80/forecastrss?p=USGA0028",
  :body => File.read(File.dirname(__FILE__) + '/fixtures/formats/weather_id/from_USGA0028.xml')
)
#
# for Google weather
#
# http://www.google.com/ig/api?weather=Calgary%2CAB&hl=en-GB
FakeWeb.register_uri(:get, 
  "http://www.google.com/ig/api?weather=#{CGI.escape('Calgary,AB')}&hl=en-GB",
  :body => File.read(File.dirname(__FILE__) + '/fixtures/services/google/calgary_ab.xml')
)
#
# for WeatherBug weather
#
# http://CODE.api.wxbug.net/getLiveWeatherRSS.aspx?ACode=CODE&OutputType=1&UnitType=1&zipCode=90210
bug_url_current = "http://#{WEATHERBUG_CODE}.api.wxbug.net:80/getLiveWeatherRSS.aspx?"
FakeWeb.register_uri(:get, 
  "#{bug_url_current}ACode=#{WEATHERBUG_CODE}&OutputType=1&UnitType=1&zipCode=90210",
  :body => File.read(File.dirname(__FILE__) + '/fixtures/services/weather_bug/90210_current.xml')
)
# http://CODE.api.wxbug.net/getForecastRSS.aspx?ACode=CODE&OutputType=1&UnitType=1&zipCode=90210
bug_url_future = "http://#{WEATHERBUG_CODE}.api.wxbug.net:80/getForecastRSS.aspx?"
FakeWeb.register_uri(:get, 
  "#{bug_url_future}ACode=#{WEATHERBUG_CODE}&OutputType=1&UnitType=1&zipCode=90210",
  :body => File.read(File.dirname(__FILE__) + '/fixtures/services/weather_bug/90210_forecast.xml')
)
#
# for weather.com weather
#
# http://xoap.weather.com:80/weather/local/90210?dayf=5&unit=m&link=xoap&par=PKEY&prod=xoap&key=LKEY&cc=*
weather_com_url = "http://xoap.weather.com:80/weather/local/"
FakeWeb.register_uri(:get, 
  "#{weather_com_url}90210?dayf=5&unit=m&link=xoap&par=#{WEATHER_PARTNER_KEY}&prod=xoap&key=#{WEATHER_LICENSE_KEY}&cc=*",
  :body => File.read(File.dirname(__FILE__) + '/fixtures/services/weather_dot_com/90210.xml')
)
#
# for yahoo weather
#
# http://weather.yahooapis.com:80/forecastrss?u=c&p=90210
FakeWeb.register_uri(:get, 
  "http://weather.yahooapis.com:80/forecastrss?u=c&p=90210",
  :body => File.read(File.dirname(__FILE__) + '/fixtures/services/yahoo/90210.xml')
)

#
# For wunderground weather
#
# http://api.wunderground.com/auto/wui/geo/WXCurrentObXML/index.xml?query=51.045%2C-114.0572222
FakeWeb.register_uri(:get, 
  "http://api.wunderground.com/auto/wui/geo/WXCurrentObXML/index.xml?query=51.04499999999999%2C-114.0572222",
  :body => File.read(File.dirname(__FILE__) + '/fixtures/services/wunderground/current_calgary_ab.xml')
)
# http://api.wunderground.com/auto/wui/geo/ForecastXML/index.xml?query=51.045%2C-114.0572222
FakeWeb.register_uri(:get, 
  "http://api.wunderground.com/auto/wui/geo/ForecastXML/index.xml?query=51.04499999999999%2C-114.0572222",
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
# curl -d "documentType=text%2Fhtml&outputType=xml&documentContent=<html><body><div class=\"geo\"><span class=\"latitude\">40.756054</span><span class=\"longitude\">-73.986951</span></div></body></html>" http://wherein.yahooapis.com/v1/document
# curl -d "documentType=text%2Fhtml&outputType=xml&documentContent=Chicago" http://wherein.yahooapis.com/v1/document
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