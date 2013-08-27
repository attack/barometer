module Barometer
  module Query
    module Format
      #
      # Base Format Class
      #
      # Fromats are used to determine if a query is of a certain
      # format, how to convert to and from that format
      # and what the country_code is for that format (if possible).
      # Some formats require external Web Services to help
      # in the converision. (ie :weather_id -> :geocode)
      #
      class Base
        @@fixes_file = File.expand_path(
          File.join(File.dirname(__FILE__), 'translations', 'weather_country_codes.yml'))
        @@fixes = nil

        def self.regex; raise NotImplementedError; end
        def self.country_code(query); nil; end

        def self.is?(query)
          !(query =~ self.regex).nil?
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
