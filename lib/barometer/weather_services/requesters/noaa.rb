module Barometer
  module Requester
    class Noaa
      def initialize(metric=true)
      end

      def get_current(query)
        puts "fetch NOAA current weather: #{query.q}" if Barometer::debug?

        response = _get("http://w1.weather.gov/xml/current_obs/#{query.q}.xml")
        _parse_for_payload(response, 'current_observation')
      end

      def get_forecast(query)
        puts "fetch NOAA forecast: #{query.q}" if Barometer::debug?

        response = _get('http://graphical.weather.gov/xml/sample_products/browser_interface/ndfdBrowserClientByDay.php', query)
        _parse_for_payload(response, 'dwml', 'data')
      end

      private

      def _get(path, query=nil)
        Barometer::Utils::Get.call(
          path, _format_request(query).merge(_format_query(query))
        )
      end

      def _parse_for_payload(response, *keys_to_unwrap)
        output = Barometer::Utils::XmlReader.parse(response, *keys_to_unwrap)
        Barometer::Utils::Payload.new(output)
      end

      def _format_request(query)
        return {} unless query

        { :format => '24 hourly', :numDays => '7' }
      end

      def _format_query(query)
        return {} unless query

        case query.format.to_sym
        when :short_zipcode
          { :zipCodeList => query.q }
        when :zipcode
          { :zipCodeList => query.q }
        when :coordinates
          { :lat => query.q.split(',')[0], :lon => query.q.split(',')[1] }
        else
          {}
        end
      end
    end
  end
end
