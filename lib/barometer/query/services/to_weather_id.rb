require_relative 'apis/weather_id'

module Barometer
  module Query
    module Service
      module ToWeatherId
        def self.call(query)
          converted_query = query.get_conversion(:geocode, :unknown)
          return unless converted_query

          api = WeatherId::Api.new(converted_query)
          _parse_content(api.get)
        end

        def self._parse_content(content)
          match = content.match(/loc id=[\\]?['|""]([0-9a-zA-Z]*)[\\]?['|""]/)
          match ? match[1] : nil
        end
      end
    end
  end
end
