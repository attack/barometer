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
          allows_nil? &&
          type_casts_as_type? &&
          sets_value? &&
          has_correct_metric_units? &&
          has_correct_imperial_units?
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

      def allows_nil?
        set_value nil
        assert value.class == NilClass, "#{@field} does not allow a nil value to be set"
      end

      def type_casts_as_type?
        set_value 10
        assert value.is_a?(@type), "#{@field} does not typecast as #{@type}"
      end

      def sets_value?
        set_value 10
        assert value.to_i == 10, "expected value of '10', got '#{value.to_i}'"
      end

      def has_correct_metric_units?
        @subject.metric = true
        set_value 10
        assert value.units == metric_units, "expected units of '#{metric_units}', got '#{value.units}'"
      end

      def has_correct_imperial_units?
        @subject.metric = false
        set_value 10
        assert value.units == imperial_units, "expected units of '#{imperial_units}', got '#{value.units}'"
      end

      private

      def value
        @subject.send(@field)
      end

      def set_value(value)
        @subject.send("#{@field}=", value)
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
