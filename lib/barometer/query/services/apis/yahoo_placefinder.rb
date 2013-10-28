module Barometer
  module Query
    module Service
      class YahooPlacefinder
        class Api < Utils::Api
          def url
            'http://query.yahooapis.com/v1/public/yql'
          end

          def params
            { q: format_query, format: :json }
          end

          def unwrap_nodes
            ['query', 'results', 0, 'Result']
          end

          private

          def format_query
            "select * from geo.placefinder where text='#{query.q}' and gflags='R'"
          end
        end
      end
    end
  end
end
