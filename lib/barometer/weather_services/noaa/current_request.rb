module Barometer
  module WeatherService
    class Noaa
      class CurrentRequest
        def initialize(query)
          @query = query
        end

        def get_weather
          Utils::PayloadRequest.new(
            "http://w1.weather.gov/xml/current_obs/#{@query.to_param}.xml",
            nil, 'current_observation'
          ).call
        end
      end
    end
  end
end
