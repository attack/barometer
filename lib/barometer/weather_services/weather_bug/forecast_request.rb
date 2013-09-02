module Barometer
  module WeatherService
    class WeatherBug
      class ForecastRequest
        def initialize(query, api_code)
          @query = query
          @api_code = api_code
        end

        def get_weather
          response = Utils::Get.call(
            "http://#{api_code}.api.wxbug.net/getForecastRSS.aspx",
            params
          )
          output = Utils::XmlReader.parse(response, 'weather', 'forecasts')
          Utils::Payload.new(output)
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
