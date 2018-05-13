module Barometer
  module Query
    module Service
      class Yahoo
        class Api < Utils::Api
          def url
            'http://query.yahooapis.com/v1/public/yql'
          end

          def params
            { q: format_query, format: :json, diagnostics: false }
          end

          def unwrap_nodes
            ['query', 'results', 'place']
          end

          private

          def format_query
            "select * from geo.places where #{field}='(#{query.q})' limit 1"
          end

          def field
            if query.format == :woe_id
              'woeid'
            else
              'text'
            end
          end
        end
      end
    end
  end
end
