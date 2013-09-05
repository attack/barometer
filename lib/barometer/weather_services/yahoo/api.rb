require 'barometer/weather_services/yahoo/query'

module Barometer
  module WeatherService
    class Yahoo
      class Api < Api
        def initialize(query)
          @query = Yahoo::Query.new(query)
        end

        def url
          'http://weather.yahooapis.com/forecastrss'
        end

        def unwrap_nodes
          ['rss', 'channel']
        end
      end
    end
  end
end
