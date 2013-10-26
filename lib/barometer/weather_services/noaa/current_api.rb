require 'barometer/weather_services/noaa/current_query'

module Barometer
  module WeatherService
    class Noaa
      class CurrentApi < Utils::Api
        def initialize(query)
          @query = CurrentQuery.new(query)
        end

        def url
          "http://w1.weather.gov/xml/current_obs/#{@query.to_param}.xml"
        end

        def params
          nil
        end

        def unwrap_nodes
          ['current_observation']
        end
      end
    end
  end
end
