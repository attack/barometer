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
        assert value.nil?, "#{@field} does not allow a nil value to be set"
      end

      def type_casts_as_type?
        if type_is_a_date?
          set_value "2013-01-01 10:15:30 am"
        elsif type_is_a_time?
          set_value "10:15:30 am"
        elsif type_is_sun?
          rise = Data::LocalDateTime.parse("10:15:30 am")
          set = Data::LocalDateTime.parse("6:14:56 pm")
          set_value Data::Sun.new(rise, set)
        else
          set_value 10
        end
        assert value.is_a?(@type), "#{@field} does not typecast as #{@type}"
      end

      def sets_value?
        if type_is_a_date?
          set_value "10 15 30 2013 01 01 am", "%H %M %S %Y %m %d %p"
          assert print_value == "2013-01-01 10:15:30 am", "expected value of '2013-01-01 10:15:30 am', got '#{print_value}'"
        elsif type_is_a_time?
          set_value "10:15:30 am"
          assert print_value == "10:15:30 am", "expected value of '10:15:30 am', got '#{print_value}'"
        elsif type_is_sun?
          rise = Data::LocalTime.parse("10:15:30 am")
          set = Data::LocalTime.parse("6:14:56 pm")
          set_value Data::Sun.new(rise, set)
          assert print_value == "rise: 10:15 am, set: 06:14 pm", "expected value of 'rise: 10:15 am, set: 06:14 pm'', got '#{print_value}'"
        else
          set_value 10
          assert value.to_i == 10, "expected value of '10', got '#{value.to_i}'"
        end
      end

      def has_correct_metric_units?
        @subject.metric = true
        return true unless value_responds_to_metric?
        set_value 10

        assert value.units == metric_units, "expected units of '#{metric_units}', got '#{value.units}'"
      end

      def has_correct_imperial_units?
        @subject.metric = false
        return true unless value_responds_to_metric?
        set_value 10

        assert value.units == imperial_units, "expected units of '#{imperial_units}', got '#{value.units}'"
      end

      private

      def value
        @subject.send(@field)
      end

      def set_value(*value)
        if type_is_a_date? || type_is_a_time?
          @subject.send("#{@field}=", value)
        else
          @subject.send("#{@field}=", *value)
        end
      end

      def print_value
        if @type == Data::LocalDateTime || @type == Data::LocalTime
          value.to_s(true)
        elsif @type == DateTime
          value.strftime("%Y-%m-%d %I:%M:%S %P")
        else
          value.to_s
        end
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
        if type_is_a_date? || type_is_a_time?
          false
        else
          @type.respond_to?(:new) && @type.send(:new).respond_to?(:metric)
        end
      end

      def type_is_a_date?
        @type == Data::LocalDateTime || @type == DateTime
      end

      def type_is_a_time?
        @type == Data::LocalTime
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
