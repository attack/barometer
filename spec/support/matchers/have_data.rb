require File.expand_path(File.dirname(__FILE__) + '/path')
require File.expand_path(File.dirname(__FILE__) + '/formats')

module Barometer
  module Matchers
    def have_data(*paths)
      HaveData.new(*paths)
    end

    class HaveData
      include Barometer::Matchers::Formats

      def initialize(*paths)
        @paths = paths
      end

      def matches?(subject)
        @result = Walker.new(subject).follow(@paths)

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
        "have correct value for #{@paths.join('.')}"
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
