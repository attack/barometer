module Barometer
  #
  # Web Service: WeatherID
  #
  # uses Weather.com search to obtain a weather id
  #
  class WebService::WeatherID < WebService
    
    # get the weather_id for a given query
    #
    def self.fetch(query)
      return nil unless query
      raise ArgumentError unless _is_a_query?(query)
      self.get(
        "http://xoap.weather.com/search/search",
        :query => { :where => query.q }, :format => :plain,
        :timeout => Barometer.timeout
      )
    end

    # get the location_date (geocode) for a given weather_id
    #
    def self.reverse(query)
      return nil unless query
      raise ArgumentError unless _is_a_query?(query)
      self.get(
        "http://weather.yahooapis.com/forecastrss",
        :query => { :p => query.q },
        :format => :xml,
        :timeout => Barometer.timeout
      )['rss']['channel']["yweather:location"]
    end

  end
end


