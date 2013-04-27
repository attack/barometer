module Barometer
  module Query
    module Format
      #
      # Weather ID (specific to weather.com)
      # eg. USGA0028
      #
      class WeatherID < Base
        def self.regex; /(^[A-Za-z]{4}[0-9]{4}$)/; end
        def self.country_code(query)
          (query && query.size >= 2) ? _fix_country(query[0..1]) : nil
        end
      end
    end
  end
end

Barometer::Query::Format.register(:weather_id, Barometer::Query::Format::WeatherID)
