module Barometer
  module Converter
    class FromShortZipcodeToZipcode
      def initialize(query)
        @query = query
      end

      def call
        return unless can_convert?
        @query.add_conversion(:zipcode, @query.get_conversion(:short_zipcode).q)
      end

      private

      def can_convert?
        !!@query.get_conversion(:short_zipcode)
      end
    end
  end
end
