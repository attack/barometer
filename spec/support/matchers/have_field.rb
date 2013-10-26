require 'rspec/expectations'

module Barometer
  module Matchers
    def have_field(field)
      HaveField.new(field)
    end

    class HaveField
      def initialize(field)
        @field = field
      end

      def matches?(subject)
        @subject = subject
        has_field? &&
          type_casts_as_type? &&
          sets_value?
      end

      def failure_message
        "Expected #{expectation} (#{@problem})"
      end

      def description
        "have data field \"#{@field}\""
      end

      def of_type(type)
        @type = type
        self
      end

      protected

      def has_field?
        assert @subject.respond_to?(@field), "does not have field '#{@field}'"
      end

      def type_casts_as_type?
        if type_is_time?
          set_value "2013-01-01 10:15:30 am"
        elsif type_is_sun?
          rise = Time.utc(2013,1,1,10,15,30)
          set = Time.utc(2013,1,1,18,14,56)
          set_value Data::Sun.new(rise: rise, set: set)
        else
          set_value 10
        end
        assert value.is_a?(@type), "#{@field} does not typecast as #{@type}"
      end

      def sets_value?
        if type_is_time?
          set_value "10 15 30 2013 01 01 am", "%H %M %S %Y %m %d %p"
          assert value.to_i == Time.utc(2013,01,01,10,15,30).to_i, "expected value of '2013-01-01 10:15:30 am', got '#{print_value}'"
        elsif type_is_sun?
          rise = Time.utc(2013,1,1,10,15,30)
          set = Time.utc(2013,1,1,18,14,56)
          set_value Data::Sun.new(rise: rise, set: set)
          assert print_value == "rise: 10:15, set: 18:14", "expected value of 'rise: 10:15, set: 18:14'', got '#{print_value}'"
        else
          set_value 10
          assert value.to_i == 10, "expected value of '10', got '#{value.to_i}'"
        end
      end

      private

      def value
        @subject.send(@field)
      end

      def set_value(*value)
        if type_is_time?
          @subject.send("#{@field}=", value)
        else
          @subject.send("#{@field}=", *value)
        end
      end

      def print_value
        value.to_s
      end

      def metric_units
        @type.send(:new, true).units
      end

      def imperial_units
        @type.send(:new, false).units
      end

      def expectation
        "\"#{@field}\" to be a #{@type}"
      end

      def value_responds_to_metric?
        if type_is_time?
          false
        elsif @type == Float
          # rubinius does not like Float.new being called on the next line
          # so avoid it
          false
        else
          @type.respond_to?(:new) && @type.new.respond_to?(:metric)
        end
      end

      def type_is_time?
        @type == Time
      end

      def type_is_sun?
        @type == Data::Sun
      end

      def assert(test, failure_message)
        if test
          true
        else
          @problem = failure_message
          false
        end
      end
    end
  end
end
