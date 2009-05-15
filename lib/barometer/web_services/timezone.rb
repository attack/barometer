module Barometer
  #
  # Web Service: Timezone
  #
  # uses geonames.org to obtain the full timezone for given coordinates
  #
  class WebService::Timezone < WebService
    
    # get the full timezone for given coordinates
    #
    def self.fetch(latitude, longitude)
      puts "timezone: #{latitude}, #{longitude}"
      return nil unless latitude && longitude
      _fetch_via_wunderground(latitude, longitude)
    end
    
    def self._fetch_via_geonames(latitude, longitude)
      response = self.get(
        "http://ws.geonames.org/timezone",
        :query => { :lat => latitude, :lng => longitude },
        :format => :xml,
        :timeout => Barometer.timeout
      )['geonames']['timezone']  
      response ? Data::Zone.new(response['timezoneId']) : nil
    end
    
    def self._fetch_via_wunderground(latitude, longitude)
      response = self.get(
        "http://api.wunderground.com/auto/wui/geo/ForecastXML/index.xml",
        :query => {:query => "#{latitude},#{longitude}"},
        :format => :xml,
        :timeout => Barometer.timeout
      )['forecast']['simpleforecast']['forecastday'].first
      response ? Data::Zone.new(response['date']['tz_long']) : nil
    end
    
  end
end


