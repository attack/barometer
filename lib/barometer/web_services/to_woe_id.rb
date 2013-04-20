require 'nokogiri'

module Barometer
  module WebService
    class ToWoeId
      def self.call(query)
        return unless _has_geocode_key?

        converted_query = query.get_conversion(:geocode, :coordinates, :postalcode)
        return unless converted_query

        response = Barometer::Http::Post.call(
          'http://wherein.yahooapis.com/v1/document', {
            'documentContent' => _construct_body(converted_query),
            'appid' => Barometer.yahoo_placemaker_app_id
          }
        )

        _parse_woe_id(Nokogiri::HTML.parse(response))
      end

      private

      def self._parse_woe_id(doc)
        doc.search('woeid').first.content
      end

      def self._construct_body(query)
        output = query.q
        if query.format == :coordinates
          microformat = "<html><body><div class=\"geo\"><span class=\"latitude\">%s</span><span class=\"longitude\">%s</span></div></body></html>"
          output = sprintf(microformat, query.q.to_s.split(',')[0], query.q.to_s.split(',')[1])
        end
        puts "placemaker adjusted query: #{output}" if Barometer::debug?
        output
      end

      def self._has_geocode_key?
        !Barometer.yahoo_placemaker_app_id.nil?
      end
    end
  end
end
