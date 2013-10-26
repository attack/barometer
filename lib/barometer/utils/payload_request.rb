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
        reader(response).parse(response.content, *api.unwrap_nodes)
      end

      private

      attr_reader :api

      def reader(response)
        if response.headers.fetch('Content-Type', '').match(/json/)
          JsonReader
        else
          XmlReader
        end
      end
    end
  end
end
