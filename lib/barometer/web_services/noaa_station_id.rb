module Barometer
  module WebService
    #
    # Web Service: NOAA Station ID
    #
    # uses noaa to find the closest station id
    #
    class NoaaStation

      # get the closest station id for given coordinates
      #
      def self.fetch(latitude, longitude)

        begin
          require 'nokogiri'
        rescue LoadError
          puts "\n****\nTo use this functionality you will need to install Nokogiri >= 1.3.3\n****\n\n"
          return nil
        end

        puts "fetching NOAA station ID near #{latitude}, #{longitude}" if Barometer::debug?
        return nil unless latitude && longitude
        _fetch_via_noaa(latitude, longitude)
      end

      # http://forecast.weather.gov/MapClick.php?textField1=LATITUDE&textField2=LONGITUDE
      def self._fetch_via_noaa(latitude, longitude)
        address =  Barometer::Http::Address.new(
          'http://forecast.weather.gov/MapClick.php?',
          { :textField1 => latitude, :textField2 => longitude }
        )
        response = Barometer::Http::Requester.get(address)

        # parse the station id from the given page
        station_id = nil

        begin
          doc = Nokogiri::HTML.parse(response)
          if doc && links = doc.search(".current-conditions-extra a")
            sid_link = links.detect{|link| link.attr("href").match(/sid=(.*)&/)}
            begin
              station_id = sid_link.attr("href").match(/sid=(.*?)&/)[1]
            rescue
            end
          end
        rescue
          puts "[ERROR] finding NOAA station near #{latitude}, #{longitude}" if Barometer::debug?
        end
        station_id
      end

    end
  end
end
