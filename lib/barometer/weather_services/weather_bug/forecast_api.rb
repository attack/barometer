require 'barometer/weather_services/weather_bug/query'

module Barometer
  module WeatherService
    class WeatherBug
      class ForecastApi < Api
        def initialize(query, api_code)
          @query = WeatherBug::Query.new(query)
          @api_code = api_code
        end

        def url
          "http://#{@api_code}.api.wxbug.net/getForecastRSS.aspx"
        end

        def params
          {ACode: @api_code, OutputType: '1'}.merge(@query.to_param)
        end

        def unwrap_nodes
          ['weather', 'forecasts']
        end
      end
    end
  end
end
