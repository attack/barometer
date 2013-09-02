module Barometer
  module WeatherService
    class WeatherBug
      class CurrentRequest
        def initialize(query, api_code)
          @query = query
          @api_code = api_code
        end

        def get_weather
          response = Utils::Get.call(
            "http://#{api_code}.api.wxbug.net/getLiveWeatherRSS.aspx",
            params
          )

          output = extract_values_that_disappear_in_conversion(response) do
            Utils::XmlReader.parse(response, 'weather', 'ob')
          end

          Utils::Payload.new(output)
        end

        private

        attr_reader :query, :api_code

        def params
          {:ACode => api_code, :OutputType => '1'}.merge(query.to_param)
        end

        def extract_values_that_disappear_in_conversion(response)
          remember_values(response)
          output = yield
          recall_values(output)

          output
        end

        def remember_values(response)
          @icon = remember_icon(response)
          @zipcode = remember_station_zipcode(response)
        end

        def recall_values(output)
          output['barometer:icon'] = @icon
          output['barometer:station_zipcode'] = @zipcode
        end

        def remember_icon(response)
          icon_match = response.match(/cond(\d*)\.gif/)
          icon_match[1] if icon_match
        end

        def remember_station_zipcode(response)
          zip_match = response.match(/zipcode=\"(\d*)\"/)
          zip_match[1] if zip_match
        end
      end
    end
  end
end
