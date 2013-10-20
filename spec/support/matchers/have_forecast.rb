require_relative 'path'
require_relative 'formats'

module Barometer
  module Matchers
    def have_forecast(*paths)
      HaveForecast.new(*paths)
    end

    class HaveForecast
      include Barometer::Matchers::Formats

      def initialize(*paths)
        @paths = paths
      end

      def matches?(subject)
        @result = Walker.new(subject.forecast[0]).follow(@paths)

        if @format
          is_of_format?(@format, @result)
        else
          @result == @value || @result.to_f == @value
        end
      end

      def failure_message
        "expected that '#{@result}' matches '#{@value || @format}'"
      end

      def description
        "have correct forecast value for #{@paths.join('.')}"
      end

      def as_value(value)
        @value = value
        self
      end

      def as_format(format)
        @format = format
        self
      end
    end
  end
end
