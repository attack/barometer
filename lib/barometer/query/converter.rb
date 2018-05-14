module Barometer
  module Query
    module Converter
      @@converters = {}

      def self.converters=(converters)
        @@converters = converters
      end

      def self.converters
        @@converters
      end

      def self.register(to_format, converter_klass)
        # return unless converter_klass.respond_to?(:from)

        @@converters[to_format] ||= {}
        converter_klass.from.each do |from_format|
          @@converters[to_format][from_format] = converter_klass
        end
      end

      def self.find(from_format, to_format)
        converter = @@converters.fetch(to_format, {}).fetch(from_format, nil)
        {to_format => converter} if converter
      end

      def self.find_all(from_format, to_formats)
        converters = _find_direct_converter(from_format, Array(to_formats))
        return converters unless converters.empty?

        _find_indirect_converters(from_format, Array(to_formats))
      end

      def self._find_direct_converter(from_format, to_formats)
        converter = nil
        to_formats.each do |to_format|
          converter = find(from_format, to_format)
          break if converter
        end
        [converter].compact
      end

      def self._find_indirect_converters(from_format, to_formats)
        geocode_converter = find(from_format, :geocode)
        converter = nil
        to_formats.each do |to_format|
          converter = find(:geocode, to_format)
          break if converter
        end
        geocode_converter && converter ? [geocode_converter, converter] : []
      end
    end
  end
end

require_relative 'converters/from_woe_id_to_geocode'
require_relative 'converters/to_woe_id'
require_relative 'converters/to_geocode'
require_relative 'converters/from_short_zipcode_to_zipcode'
require_relative 'converters/from_zipcode_to_short_zipcode'
require_relative 'converters/to_weather_id'
require_relative 'converters/from_coordinates_to_noaa_station_id'
require_relative 'converters/from_geocode_to_coordinates'
