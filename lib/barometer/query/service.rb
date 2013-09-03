module Barometer
  module Query
    module Service
    end
  end
end

require 'barometer/query/services/google_geocode'
require 'barometer/query/services/yahoo_geocode'
require 'barometer/query/services/to_weather_id'
require 'barometer/query/services/timezone'
require 'barometer/query/services/to_woe_id'
require 'barometer/query/services/noaa_station_id'
