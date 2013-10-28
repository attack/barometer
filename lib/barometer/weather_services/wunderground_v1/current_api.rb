require_relative 'query'

module Barometer
  module WeatherService
    class WundergroundV1
      class CurrentApi < Utils::Api
        def initialize(query)
          @query = WundergroundV1::Query.new(query)
        end

        def url
          'http://api.wunderground.com/auto/wui/geo/WXCurrentObXML/index.xml'
        end

        def unwrap_nodes
          ['current_observation']
        end
      end
    end
  end
end
