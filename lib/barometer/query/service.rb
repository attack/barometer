module Barometer
  module Query
    module Service
    end
  end
end

require_relative 'services/google_geocode'
require_relative 'services/yahoo_geocode'
require_relative 'services/to_weather_id'
require_relative 'services/to_woe_id'
require_relative 'services/noaa_station_id'
