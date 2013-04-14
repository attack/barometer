module Barometer
  module WebService
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
        address =  Barometer::Http::Address.new(
          'http://ws.geonames.org/timezone',
          { :lat => latitude, :lng => longitude }
        )
        response = Barometer::Http::Requester.get(address)
        timezoneId = Barometer::JsonReader.parse(response, 'geonames', 'timezone', 'timezoneId')
        timezoneId ? Data::Zone.new(timezoneId) : nil
      end

      def self._fetch_via_wunderground(latitude, longitude)
        address =  Barometer::Http::Address.new(
          'http://api.wunderground.com/auto/wui/geo/ForecastXML/index.xml',
          {:query => "#{latitude},#{longitude}"}
        )
        response = Barometer::Http::Requester.get(address)
        date = Barometer::JsonReader.parse(response, 'forecast', 'simpleforecast', 'forecastday').first
        date ? Data::Zone.new(response['date']['tz_long']) : nil
      end

    end
  end
end
