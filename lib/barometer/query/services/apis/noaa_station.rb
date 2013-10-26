module Barometer
  module Query
    module Service
      class NoaaStation
        class Api < Utils::Api
          def url
            'http://forecast.weather.gov/MapClick.php'
          end

          def params
            { textField1: latitude, textField2: longitude }
          end

          def get
            Utils::Get.call(url, params).content
          end

          private

          def latitude
            query.q.split(',')[0]
          end

          def longitude
            query.q.split(',')[1]
          end
        end
      end
    end
  end
end
