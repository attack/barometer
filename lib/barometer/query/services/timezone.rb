module Barometer
  module Query
    module Service
      #
      # Web Service: Timezone
      #
      # uses geonames.org to obtain the full timezone for given coordinates
      #
      class Timezone

        # get the full timezone for given coordinates
        #
        def self.fetch(latitude, longitude)
          puts "timezone: #{latitude}, #{longitude}"
          return nil unless latitude && longitude
          _fetch_via_wunderground(latitude, longitude)
        end

        def self._fetch_via_geonames(latitude, longitude)
          response =  Barometer::Utils::Get.call(
            'http://ws.geonames.org/timezone',
            { :lat => latitude, :lng => longitude }
          )
          timezoneId = Barometer::Utils::JsonReader.parse(response, 'geonames', 'timezone', 'timezoneId')
          timezoneId ? Data::Zone.new(timezoneId) : nil
        end

        def self._fetch_via_wunderground(latitude, longitude)
          response =  Barometer::Utils::Get.call(
            'http://api.wunderground.com/auto/wui/geo/ForecastXML/index.xml',
            {:query => "#{latitude},#{longitude}"}
          )
          date = Barometer::Utils::JsonReader.parse(response, 'forecast', 'simpleforecast', 'forecastday').first
          date ? Data::Zone.new(response['date']['tz_long']) : nil
        end
      end
    end
  end
end
