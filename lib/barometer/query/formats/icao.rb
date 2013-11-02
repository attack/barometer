module Barometer
  module Query
    module Format
      #
      # ICAO (International Civil Aviation Organization)
      # eg. KLAX (Los Angeles Airport)
      #
      class Icao < Base
        @@codes_file = File.expand_path(
          File.join(File.dirname(__FILE__), 'translations', 'icao_country_codes.yml'))
        @@codes = nil

        # call any 3-4 letter query, :icao ... obviously this will have a lot
        # of false positives.  So far this isn't an issue as all weather services
        # that take :icao (which is just one, :wunderground) also take what
        # this would have been if it was not called :icao.
        #
        def self.regex; /^[A-Za-z]{3,4}$/; end

        # in some cases the first letter can designate the country
        #
        def self.geo(query)
          return unless query && query.is_a?(String)
          $:.unshift(File.dirname(__FILE__))
          @@codes ||= YAML.load_file(@@codes_file)
          return unless @@codes && @@codes['one_letter'] && @@codes['two_letter']
          country_code = @@codes['one_letter'][query[0..0].upcase.to_s] ||
            @@codes['two_letter'][query[0..1].upcase.to_s] || nil

          {country_code: country_code}
        end
      end
    end
  end
end

Barometer::Query::Format.register(:icao, Barometer::Query::Format::Icao)
