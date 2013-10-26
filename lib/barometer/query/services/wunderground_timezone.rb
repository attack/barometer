require_relative 'apis/wunderground_timezone'

module Barometer
  module Query
    module Service
      class WundergroundTimezone
        def self.fetch(latitude, longitude)
          return unless latitude && longitude

          api = WundergroundTimezone::Api.new(latitude, longitude)
          payload = api.get

          Data::Zone.new( payload.fetch('date', 'tz_long') )
        end
      end
    end
  end
end
