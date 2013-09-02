module Barometer
  module WeatherService
    class Noaa
      class ForecastRequest
        def initialize(query)
          @query = query
        end

        def get_weather
          Utils::PayloadRequest.new(
            'http://graphical.weather.gov/xml/sample_products/browser_interface/ndfdBrowserClientByDay.php',
            @query.to_param, 'dwml', 'data'
          ).call
        end
      end
    end
  end
end
