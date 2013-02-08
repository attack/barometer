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
      puts "fetch weather_id: #{query.q}" if Barometer::debug?
      return nil unless query
      raise ArgumentError unless _is_a_query?(query)

      self.get(
        "http://xoap.weather.com/search/search",
        :query => { :where => _adjust_query(query.q) }, :format => :plain,
        :timeout => Barometer.timeout
      )
    end

    # get the location_date (geocode) for a given weather_id
    #
    def self.reverse(query)
      puts "reverse weather_id: #{query.q}" if Barometer::debug?
      return nil unless query
      raise ArgumentError unless _is_a_query?(query)
      self.get(
        "http://weather.yahooapis.com/forecastrss",
        :query => { :p => query.q },
        :format => :xml,
        :timeout => Barometer.timeout
      )['rss']['channel']["yweather:location"]
    end

    # filter out words that weather.com has trouble geo-locating
    # mostly these are icao related
    #
    def self._adjust_query(query)
      output = query.dup
      words_to_remove = %w(international airport municipal)
      words_to_remove.each do |word|
        output.gsub!(/#{word}/i, "")
      end
      output
    end

  end
end


