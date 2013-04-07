module Barometer
  class Converters
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
      @@converters.fetch(to_format, {}).fetch(from_format, nil)
    end

    def self.find_all(from_format, to_formats)
      _find_direct_converter(from_format, Array(to_formats)) ||
        _find_indirect_converters(from_format, Array(to_formats))
    end

    def self._find_direct_converter(from_format, to_formats)
      converter = nil
      to_formats.each do |to_format|
        converter = find(from_format, to_format)
        break if converter
      end
      converter
    end

    def self._find_indirect_converters(from_format, to_formats)
      geocode_converter = find(from_format, :geocode)
      converter = nil
      to_formats.each do |to_format|
        converter = find(:geocode, to_format)
        break if converter
      end
      [geocode_converter, converter] if geocode_converter && converter
    end
  end
end
