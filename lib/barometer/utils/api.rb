module Barometer
  module Utils
    class Api
      attr_reader :query

      def initialize(query)
        @query = query
      end

      def current_query
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
