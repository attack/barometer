module Barometer
  module Query
    class Base
      attr_reader :format, :geo, :units

      def initialize(query, units=:metric)
        @q = query.dup
        @units = units
        detect_format
        freeze_query
        @conversions = {}
      end

      def q
        @format_klass.convert_query(@q)
      end

      def add_conversion(format, q)
        return unless q

        @conversions[format] = q
        converted_query(q, format)
      end

      def get_conversion(*formats)
        converted_format = formats.detect{|f| format == f || @conversions.has_key?(f)}
        return unless converted_format

        if converted_format == format
          self
        else
          converted_query(@conversions[converted_format], converted_format)
        end
      end

      def convert!(*preferred_formats)
        return self if preferred_formats.include?(format)

        get_conversion(*preferred_formats) ||
          do_conversion(format, preferred_formats) ||
          raise(ConversionNotPossible)
      end

      def metric?
        units == :metric
      end

      def to_s
        q.to_s
      end

      def geo=(geo)
        @geo = @geo.merge(geo)
      end

      private

      def converted_query(q, format)
        ConvertedQuery.new(q, format, units, geo)
      end

      def detect_format
        Format.match?(@q) do |key, klass|
          @format = key
          @geo = Data::Geo.new(klass.geo(@q))
          @format_klass = klass
        end
      end

      def freeze_query
        @q.freeze
        @format.freeze
        @units.freeze
      end

      def do_conversion(format, preferred_formats)
        converters = Converter.find_all(format, preferred_formats)
        result = converters.map do |converter|
          to_format = converter.keys.first
          converter_klass = converter.values.first
          get_conversion(to_format) || converter_klass.new(self).call
        end.last
        get_conversion(*preferred_formats) || result
      end
    end
  end
end
