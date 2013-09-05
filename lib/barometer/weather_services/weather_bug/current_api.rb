require 'barometer/weather_services/weather_bug/query'

module Barometer
  module WeatherService
    class WeatherBug
      class CurrentApi < Api
        def initialize(query, api_code)
          @query = WeatherBug::Query.new(query)
          @api_code = api_code
        end

        def url
          "http://#{@api_code}.api.wxbug.net/getLiveWeatherRSS.aspx"
        end

        def params
          {:ACode => @api_code, :OutputType => '1'}.merge(@query.to_param)
        end

        def unwrap_nodes
          ['weather', 'ob']
        end

        def before_parse(response)
          @icon = remember_icon(response)
          @zipcode = remember_station_zipcode(response)
        end

        def after_parse(output)
          output['barometer:icon'] = @icon
          output['barometer:station_zipcode'] = @zipcode
        end

        private

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
