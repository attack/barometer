module Barometer
  module WeatherService
    class WundergroundV1
      class ForecastRequest
        def initialize(query)
          @query = query
        end

        def get_weather
          response = Utils::Get.call(
            'http://api.wunderground.com/auto/wui/geo/ForecastXML/index.xml',
            query.to_param
          )
          output = Utils::XmlReader.parse(response, 'forecast')
          Utils::Payload.new(output)
        end

        private

        attr_reader :query
      end
    end
  end
end
