require_relative 'query'

module Barometer
  module WeatherService
    class WundergroundV1
      class ForecastApi < Utils::Api
        def initialize(query)
          @query = WundergroundV1::Query.new(query)
        end

        def url
          'http://api.wunderground.com/auto/wui/geo/ForecastXML/index.xml'
        end

        def unwrap_nodes
          ['forecast']
        end
      end
    end
  end
end
