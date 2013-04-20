module Barometer
  module WebService
    class FromWeatherId
      def self.call(query)
        converted_query = query.get_conversion(:weather_id)
        return unless converted_query
        puts "reverse weather_id: #{converted_query.q}" if Barometer::debug?

        response =  Barometer::Http::Get.call(
          'http://weather.yahooapis.com/forecastrss',
          { :p => converted_query.q }
        )
        Barometer::XmlReader.parse(response, 'rss', 'channel')
      end

      def self.parse_geocode(response)
        [response['location']['@city'], response['location']['@region'], response['location']['@country']].
          select{|r|!r.empty?}.join(', ')
      end

      def self.parse_coordinates(response)
        [response['item']['lat'], response['item']['long']].select{|r|!r.empty?}.join(',')
      end
    end
  end
end
