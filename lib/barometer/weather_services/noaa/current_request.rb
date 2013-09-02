module Barometer
  module WeatherService
    class Noaa
      class CurrentRequest
        def initialize(query)
          @query = query
        end

        def get_weather
          response = Utils::Get.call("http://w1.weather.gov/xml/current_obs/#{query.to_param}.xml")
          output = Utils::XmlReader.parse(response, 'current_observation')
          Utils::Payload.new(output)
        end

        private

        attr_reader :query
      end
    end
  end
end
