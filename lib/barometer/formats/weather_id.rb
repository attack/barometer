module Barometer
  #
  # Weather ID (specific to weather.com)
  # eg. USGA0028
  #
  class Query::Format::WeatherID < Query::Format
    def self.regex; /(^[A-Za-z]{4}[0-9]{4}$)/; end
    def self.country_code(query)
      (query && query.size >= 2) ? _fix_country(query[0..1]) : nil
    end
  end
end

Barometer::Formats.register(:weather_id, Barometer::Query::Format::WeatherID)
