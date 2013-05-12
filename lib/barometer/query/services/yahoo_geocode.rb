module Barometer
  module Query
    module Service
      class YahooGeocode
        def self.call(query)
          converted_query = query.get_conversion(:woe_id, :weather_id)
          return unless converted_query
          puts "reverse #{converted_query.format}: #{converted_query.q}" if Barometer::debug?

          response =  Barometer::Utils::Get.call(
            'http://weather.yahooapis.com/forecastrss',
            _format_query(converted_query)
          )

          Barometer::Utils::XmlReader.parse(response, 'rss', 'channel') do |result|
            _parse_result(result)
          end
        end

        def self._parse_result(result)
          payload = Utils::Payload.new(result)

          Data::Geo.new.tap do |geo|
            geo.locality = payload.fetch('location', '@city')
            geo.region = payload.fetch('location', '@region')
            _parse_country(geo, payload)
            geo.latitude = payload.fetch('item', 'lat').to_f
            geo.longitude = payload.fetch('item', 'long').to_f
          end
        end

        private

        def self._format_query(query)
          if query.format == :woe_id
            { :w => query.q }
          else
            puts "[WARNING] - converting #{query.format} -> geocode is deprecated by Yahoo! Weather" if Barometer::debug?
            { :p => query.q }
          end
        end

        def self._parse_country(geo, payload)
          if (country = payload.fetch('location', '@country')).size > 2
            geo.country = country
          else
            geo.country_code = country
          end
        end
      end
    end
  end
end
