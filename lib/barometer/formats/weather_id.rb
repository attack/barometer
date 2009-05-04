module Barometer
  #
  # Weather ID (specific to weather.com)
  #
  # eg. USGA0028
  #
  class Query::WeatherID < Query::Format
  
    def self.regex
      /(^[A-Za-z]{4}[0-9]{4}$)/
    end
  
    def self.format
      :weather_id
    end
  
    # the first two letters of the :weather_id is the country_code
    def self.country_code(query=nil)
      return ArgumentError unless query.is_a?(String)
      (query && query.size >= 2) ? query[0..1] : nil
    end
  
    # convert to this format
    def self.to(current_query, current_format)
      
      skip_formats = [:weather_id, :postalcode, :icao]
      return nil if skip_formats.include?(current_format)
      
      geo_query = nil
      if current_format == :geocode
        geo_query = current_query
      else
        geo_query, country_code, geo = Barometer::Query::Geocode.to(current_query, current_format)
      end
      [_search(geo_query), country_code, geo]
    end
    
    # reverse lookup
    def self.from(query=nil)
      _reverse(query)
    end
    
    private
    
    # :geocode -> :weather_id
    # search weather.com for the given query
    def self._search(query=nil)
      return nil unless query
      response = Barometer::Query.get(
        "http://xoap.weather.com/search/search",
        :query => { :where => query },
        :format => :plain,
        :timeout => Barometer.timeout
      )
      if response
        begin
          res_match = response.match(/loc id='([0-9a-zA-Z]*)'/)
          return res_match[1] if res_match
        rescue
          return nil
        end
      else
        return nil
      end
    end
    
    # :weather_id -> :geocode
    # Yahoo! understands :weather_id as a query.  Get response from
    # Yahoo! and parse the location data
    def self._reverse(query=nil)
      return nil unless query
      response = Barometer::Query.get(
        "http://weather.yahooapis.com/forecastrss",
        :query => {:p => query },
        :format => :xml,
        :timeout => Barometer.timeout
      )['rss']['channel']
      if response && response["yweather:location"]
        location = response["yweather:location"]
        return [location["city"], location["region"], location["country"]].join(', ')
      else
        return nil
      end
    end

  end
end