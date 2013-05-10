module Barometer
  module Query
    module Service
      module ToWeatherId
        def self.call(query)
          converted_query = query.get_conversion(:geocode, :unknown)
          return unless converted_query
          puts "fetch weather_id: #{converted_query.q}" if Barometer::debug?

          response = Barometer::Utils::Get.call(
            'http://xoap.weather.com/search/search',
            { :where => _format_query(converted_query.q) }
          )
          _format_response(response)
        end

        # filter out words that weather.com has trouble geo-locating
        # mostly these are icao related
        #
        def self._format_query(query)
          output = query.dup
          words_to_remove = %w(international airport municipal)
          words_to_remove.each do |word|
            output.gsub!(/#{word}/i, "")
          end
          output
        end

        def self._format_response(response)
          match = response.match(/loc id=[\\]?['|""]([0-9a-zA-Z]*)[\\]?['|""]/)
          match ? match[1] : nil
        end
      end
    end
  end
end
