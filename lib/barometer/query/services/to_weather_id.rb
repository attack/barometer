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

        def self._parse_content(payload)
          if payload.fetch('loc').is_a? Array
            payload.fetch('loc', 0, '@id')
          else
            payload.fetch('loc', '@id')
          end
        end
      end
    end
  end
end
