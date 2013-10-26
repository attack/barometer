module Barometer
  module Utils
    class Api
      attr_reader :query

      def initialize(query)
        @query = query
      end

      def current_query
        @query.converted_query if @query.respond_to?(:converted_query)
      end

      def url
      end

      def params
        @query.to_param
      end

      def unwrap_nodes
        []
      end

      def get
        Utils::PayloadRequest.new(self).get
      end
    end
  end
end
