module Barometer
  module WeatherService
    class WundergroundV1
      class ForecastRequest
        def initialize(query)
          @query = query
        end

        def get_weather
          Utils::PayloadRequest.new(
            'http://api.wunderground.com/auto/wui/geo/ForecastXML/index.xml',
            @query.to_param, 'forecast'
          ).call
        end
      end
    end
  end
end
