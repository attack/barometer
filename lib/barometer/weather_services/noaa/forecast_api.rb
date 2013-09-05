require 'barometer/weather_services/noaa/forecast_query'

module Barometer
  module WeatherService
    class Noaa
      class ForecastApi < Api
        def initialize(query)
          @query = ForecastQuery.new(query)
        end

        def url
          'http://graphical.weather.gov/xml/sample_products/browser_interface/ndfdBrowserClientByDay.php'
        end

        def unwrap_nodes
          ['dwml', 'data']
        end
      end
    end
  end
end
