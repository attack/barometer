module Barometer
  module WeatherService
    class Yahoo
      class Request
        def initialize(query)
          @query = query
        end

        def get_weather
          Utils::PayloadRequest.new(
            'http://weather.yahooapis.com/forecastrss',
            @query.to_param, 'rss', 'channel'
          ).call
        end
      end
    end
  end
end
