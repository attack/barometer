module Barometer
  #
  # Format: Weather ID (specific to weather.com)
  #
  # eg. USGA0028
  #
  # This class is used to determine if a query is a
  # :weather_id, how to convert to and from :weather_id
  # and what the country_code is.
  #
  class Query::Format::WeatherID < Query::Format
    def self.format; :weather_id; end
    def self.regex; /(^[A-Za-z]{4}[0-9]{4}$)/; end

    # the first two letters of the :weather_id is the country_code
    #
    def self.country_code(query=nil)
      (query && query.size >= 2) ? _fix_country(query[0..1]) : nil
    end
  end
end

Barometer::Query.register(:weather_id, Barometer::Query::Format::WeatherID)
