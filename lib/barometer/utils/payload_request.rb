module Barometer
  module Utils
    class PayloadRequest
      def initialize(url, params, *nodes_to_remove)
        @url = url
        @params = params
        @nodes_to_remove = nodes_to_remove
      end

      def call
        response = make_request
        output = parse_response(response)
        Payload.new(output)
      end

      private

      def make_request
        Get.call(@url, @params)
      end

      def parse_response(response)
        XmlReader.parse(response, *@nodes_to_remove)
      end
    end
  end
end
