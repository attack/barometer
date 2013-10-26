module Barometer
  module Query
    module Service
      class WundergroundTimezone
        class Api < Utils::Api
          def initialize(latitude, longitude)
            @latitude = latitude
            @longitude = longitude
          end

          def url
            'http://api.wunderground.com/auto/wui/geo/ForecastXML/index.xml'
          end

          def params
            { query: "#{@latitude},#{@longitude}" }
          end

          def unwrap_nodes
            ['forecast', 'simpleforecast', 'forecastday', 0]
          end
        end
      end
    end
  end
end
