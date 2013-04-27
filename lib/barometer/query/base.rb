module Barometer
  module Query
    class Base
      attr_reader :format
      attr_accessor :country_code, :geo, :timezone

      def initialize(query)
        @q = query
        detect_format
        freeze_query
        @conversions = {}
      end

      def q
        if @format_klass.respond_to?(:convert_query)
          @format_klass.convert_query(@q)
        else
          @q
        end
      end

      def add_conversion(format, q)
        return unless q

        @conversions[format] = q
        converted_query(q, format)
      end

      def get_conversion(*formats)
        converted_format = formats.detect{|f| format == f || @conversions.has_key?(f)}
        return unless converted_format

        puts "found: #{format} -> #{converted_format} = #{q} -> #{@conversions[converted_format]}" if Barometer::debug?
        if converted_format == format
          self
        else
          converted_query(@conversions[converted_format], converted_format)
        end
      end

      def convert!(*preferred_formats)
        return self if preferred_formats.include?(format)

        converters = Barometer::Query::Converter.find_all(format, preferred_formats)

        [converters].flatten.map {|converter| converter.new(self).call}.last ||
          raise(Barometer::Query::ConversionNotPossible)
      end

      private

      def converted_query(q, format)
        Barometer::ConvertedQuery.new(q, format, country_code, geo)
      end

      def detect_format
        Barometer::Formats.match?(@q) do |key, klass|
          @format = key
          @country_code = klass.country_code(@q)
          @format_klass = klass
        end
      end

      def freeze_query
        @q.freeze
        @format.freeze
      end
    end
  end
end
