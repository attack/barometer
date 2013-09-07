require 'barometer/utils/data_types'
require 'virtus'

module Barometer
  module Response
    class Prediction
      include Virtus
      include Barometer::Utils::DataTypes

      attribute :pop, Float, :writer_class => Data::FloatWriter
      attribute :icon, String
      attribute :condition, String

      time :starts_at, :ends_at
      temperature :high, :low
      sun :sun

      attr_reader :date

      def initialize(metric=true)
        @metric = metric
      end

      def date=(args)
        args = [args] unless args.is_a?(Array)
        date = args.shift
        timezone = args.shift

        if date.is_a?(Date)
          @date = date
        elsif date.respond_to?(:to_date)
          @date = date.to_date
        else
          @date = Date.parse(date)
        end
        @starts_at = Time.utc(@date.year,@date.month,@date.day,0,0,0)
        @ends_at = Time.utc(@date.year,@date.month,@date.day,23,59,59)

        # NOT TESTED
        if timezone
          @starts_at = timezone.local_to_utc(@starts_at)
          @ends_at = timezone.local_to_utc(@ends_at)
        end
      end

      def covers?(time)
        raise ArgumentError unless time.is_a?(Time)
        time >= @starts_at && time <= @ends_at
      end
    end
  end
end
