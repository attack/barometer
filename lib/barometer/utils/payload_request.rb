module Barometer
  module Utils
    class PayloadRequest
      def initialize(api)
        @api = api
      end

      def get
        response = make_request
        output = parse_response(response)
        Payload.new(output, api.current_query)
      end

      private

      def make_request
        Get.call(api.url, api.params)
      end

      def parse_response(response)
        using_around_filters(response) do
          reader.parse(response, *api.unwrap_nodes)
        end
      end

      private

      attr_reader :api

      def using_around_filters(response)
        api.before_parse(response) if api.respond_to?(:before_parse)
        output = yield
        api.after_parse(output) if api.respond_to?(:after_parse)
        output
      end

      def reader
        json? ? JsonReader : XmlReader
      end

      def json?
        api.respond_to?(:format) && api.format == :json
      end
    end
  end
end
