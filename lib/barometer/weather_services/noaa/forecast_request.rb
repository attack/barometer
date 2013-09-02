module Barometer
  module WeatherService
    class Noaa
      class ForecastRequest
        def initialize(query)
          @query = query
        end

        def get_weather
          response = Utils::Get.call(
            'http://graphical.weather.gov/xml/sample_products/browser_interface/ndfdBrowserClientByDay.php',
            query.to_param
          )
          output = Utils::XmlReader.parse(response, 'dwml', 'data')
          Utils::Payload.new(output)
        end

        private

        attr_reader :query
      end
    end
  end
end
