require 'nokogiri'

module Barometer
  module WebService
    #
    # NOAA Station ID
    # - uses noaa to find the closest station id
    #
    class NoaaStation
      def self.fetch(query)
        converted_query = query.get_conversion(:coordinates)
        return unless converted_query
        puts "fetching NOAA station ID near #{converted_query.q}" if Barometer::debug?

        _fetch_via_noaa(converted_query)
      end

      def self._fetch_via_noaa(converted_query)
        address =  Barometer::Http::Address.new(
          'http://forecast.weather.gov/MapClick.php?',
          _format_params(converted_query)
        )
        response = Barometer::Http::Requester.get(address)
        _parse_station_id(response)
      end

      def self._format_params(query)
        latitude = query.q.split(',')[0]
        longitude = query.q.split(',')[1]

        { :textField1 => latitude, :textField2 => longitude }
      end

      def self._parse_station_id(response)
        doc = Nokogiri::HTML.parse(response)
        if doc && links = doc.search(".current-conditions-extra a")
          sid_link = links.detect{|link| link.attr("href").match(/sid=(.*)&/)}
          begin
            sid_link.attr("href").match(/sid=(.*?)&/)[1]
          rescue
            nil
          end
        end
      rescue
        puts "[ERROR] finding NOAA station" if Barometer::debug?
        nil
      end
    end
  end
end
