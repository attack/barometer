module Barometer
  module WeatherService
    class WundergroundV1
      class CurrentRequest
        def initialize(query)
          @query = query
        end

        def get_weather
          Utils::PayloadRequest.new(
            'http://api.wunderground.com/auto/wui/geo/WXCurrentObXML/index.xml',
            @query.to_param, 'current_observation'
          ).call
        end
      end
    end
  end
end
