module Barometer
  module Utils
    class PayloadRequest
      def initialize(api)
        @api = api
      end

      def get
        response = make_request
        output = parse_response(response.content)
        Payload.new(output, api.current_query)
      end

      private

      def make_request
        Get.call(api.url, api.params)
      end

      def parse_response(response)
        reader.parse(response, *api.unwrap_nodes)
      end

      private

      attr_reader :api

      def reader
        json? ? JsonReader : XmlReader
      end

      def json?
        api.respond_to?(:format) && api.format == :json
      end
    end
  end
end
