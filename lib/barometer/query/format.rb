module Barometer
  module Query
    module Format
      class NotFound < StandardError; end

      @@formats = []

      def self.formats=(formats)
        @@formats = formats
      end

      def self.formats
        @@formats
      end

      def self.register(key, format)
        @@formats ||= []
        @@formats << [ key.to_sym, format ] unless has?(key)
      end

      def self.has?(key)
        !@@formats.select{|format| format[0] == key.to_sym}.empty?
      end

      def self.find(key)
        @@formats ||= []
        format = @@formats.select{|format| format[0] == key.to_sym}

        if format && format[0]
          format[0][1]
        else
          raise NotFound
        end
      end

      def self.match?(q)
        @@formats.detect do |key, klass|
          if klass.is?(q)
            yield(key, klass)
            true
          end
        end
      end
    end
  end
end

require 'barometer/query/formats/base'
require 'barometer/query/formats/short_zipcode'
require 'barometer/query/formats/zipcode'
require 'barometer/query/formats/postalcode'
require 'barometer/query/formats/weather_id'
require 'barometer/query/formats/coordinates'
require 'barometer/query/formats/icao'
require 'barometer/query/formats/woe_id'
require 'barometer/query/formats/unknown'
require 'barometer/query/formats/noaa_station_id'
require 'barometer/query/formats/geocode'
