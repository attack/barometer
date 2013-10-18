require 'barometer/utils/data_types'
require 'virtus'

module Barometer
  module Response
    class Prediction
      include Virtus.model
      include Utils::DataTypes

      attribute :high, Data::Attribute::Temperature
      attribute :low, Data::Attribute::Temperature
      attribute :pop, Data::Attribute::Float
      attribute :sun, Data::Attribute::Sun
      attribute :starts_at, Data::Attribute::Time
      attribute :ends_at, Data::Attribute::Time
      attribute :icon, String
      attribute :condition, String

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
