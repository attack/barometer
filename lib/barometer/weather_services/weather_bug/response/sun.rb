require_relative 'time_helper'

module Barometer
  module WeatherService
    class WeatherBug
      class Response
        class Sun
          def initialize(payload, timezone)
            @payload = payload
            @timezone = timezone
          end

          def parse
            Data::Sun.new(rise: local_sunrise_time, set: local_sunset_time)
          end

          private

          attr_reader :payload, :timezone

          def local_sunrise_time
            TimeHelper.new(payload, timezone).parse('sunrise')
          end

          def local_sunset_time
            TimeHelper.new(payload, timezone).parse('sunset')
          end
        end
      end
    end
  end
end
