module Barometer
  module WeatherService
    module Response
      class Location
        def initialize(payload)
          @payload = payload
        end

        def parse
          Data::Location.new(
            id: id,
            name: name,
            city: city,
            state_name: state_name,
            state_code: state_code,
            country: country,
            country_code: country_code,
            zip_code: zip_code,
            latitude: latitude,
            longitude: longitude
          )
        end

        private

        attr_reader :payload

        def id; end
        def name; end
        def city; end
        def state_name; end
        def state_code; end
        def country; end
        def country_code; end
        def zip_code; end
        def zip_code; end
        def latitude; end
        def longitude; end
      end
    end
  end
end
