module Barometer
  module Query
    module Format
      #
      # Weather ID (specific to weather.com)
      # eg. USGA0028
      #
      class WeatherID < Base
        @@fixes_file = File.expand_path(
          File.join(File.dirname(__FILE__), 'translations', 'weather_country_codes.yml'))
        @@fixes = nil

        def self.regex; /(^[A-Za-z]{4}[0-9]{4}$)/; end

        def self.geo(query)
          if query && query.size >= 2
            { country_code: _fix_country(query[0..1]) }
          end
        end

        private

        # weather.com uses non-standard two letter country codes that
        # hinder the ability to determine the country or fetch geo_data.
        # correct these "mistakes"
        #
        def self._fix_country(country_code)
          @@fixes ||= YAML.load_file(@@fixes_file)
          @@fixes[country_code.upcase.to_s] || country_code
        end
      end
    end
  end
end

Barometer::Query::Format.register(:weather_id, Barometer::Query::Format::WeatherID)
