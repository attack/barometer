module Barometer
  module WeatherService
    class Yahoo
      class Request
        def initialize(query)
          @query = query
        end

        def get_weather
          response = Utils::Get.call(
            'http://weather.yahooapis.com/forecastrss',
            query.to_param
          )
          output = Utils::XmlReader.parse(response, 'rss', 'channel')
          Utils::Payload.new(output)
        end

        private

        attr_reader :query
      end
    end
  end
end
