module Barometer
  module WeatherService
    module Response
      class TimeZone
        def initialize(payload)
          @payload = payload
        end

        def parse
          Data::Zone.new(time_zone)
        end

        private

        attr_reader :payload
      end
    end
  end
end
