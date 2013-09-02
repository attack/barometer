module Barometer
  module WeatherService
    class WeatherBug
      class ForecastRequest
        def initialize(query, api_code)
          @query = query
          @api_code = api_code
        end

        def get_weather
          Utils::PayloadRequest.new(
            "http://#{api_code}.api.wxbug.net/getForecastRSS.aspx",
            params, 'weather', 'forecasts'
          ).call
        end

        private

        attr_reader :query, :api_code

        def params
          {:ACode => api_code, :OutputType => '1'}.merge(query.to_param)
        end
      end
    end
  end
end
