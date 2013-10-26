require_relative 'apis/geonames_timezone'

module Barometer
  module Query
    module Service
      class GeonamesTimezone
        def self.fetch(latitude, longitude)
          return unless latitude && longitude

          api = GeonamesTimezone::Api.new(latitude, longitude)
          payload = api.get

          Data::Zone.new( payload.fetch('timezoneId') )
        end
      end
    end
  end
end
