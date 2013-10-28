module Barometer
  module Query
    module Service
      class YahooWeather
        class Api < Utils::Api
          def url
            'http://weather.yahooapis.com/forecastrss'
          end

          def params
            format_params
          end

          def unwrap_nodes
            ['rss', 'channel']
          end

          private

          def format_params
            if query.format == :woe_id
              { w: query.q }
            else
              { p: query.q }
            end
          end
        end
      end
    end
  end
end
