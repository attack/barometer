module Barometer
  module Query
    module Service
      class NoaaStation
        class Api < Utils::Api
          def url
            "https://api.weather.gov/points/#{query.q}/stations"
          end

          def unwrap_nodes
            ['features', 0, 'properties', 'stationIdentifier']
          end

          def get
            content = Utils::GetContent.call(url)
            Utils::JsonReader.parse(content, *unwrap_nodes)
          end
        end
      end
    end
  end
end
