module Barometer
  module WeatherService
    class Yahoo
      class Response
        class Sun
          def initialize(payload, base_time)
            @payload = payload
            @base_time = base_time
          end

          def parse
            return if local_rise_time.nil? || local_set_time.nil?
            Data::Sun.new(utc_rise_time, utc_set_time)
          end

          private

          attr_reader :payload, :base_time

          def local_rise_time
            @local_rise_time ||= Utils::Time.parse(payload.fetch('astronomy', '@sunrise'))
          end

          def local_set_time
            @local_set_time ||= Utils::Time.parse(payload.fetch('astronomy', '@sunset'))
          end

          def utc_rise_time
            Utils::Time.utc_from_base_plus_local_time(
              base_time.timezone, base_time.base, local_rise_time.hour, local_rise_time.min
            )
          end

          def utc_set_time
            Utils::Time.utc_from_base_plus_local_time(
              base_time.timezone, base_time.base, local_set_time.hour, local_set_time.min
            )
          end
        end
      end
    end
  end
end
