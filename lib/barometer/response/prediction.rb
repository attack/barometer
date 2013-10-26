require 'virtus'

module Barometer
  module Response
    class Prediction
      include Virtus.model

      attribute :high, Data::Attribute::Temperature
      attribute :low, Data::Attribute::Temperature
      attribute :pop, Data::Attribute::Float
      attribute :sun, Data::Attribute::Sun
      attribute :starts_at, Data::Attribute::Time
      attribute :ends_at, Data::Attribute::Time
      attribute :icon, String
      attribute :condition, String

      attr_reader :date

      def date=(args)
        args = Array(args)
        date = args.shift
        timezone = args.shift

        date_as_time = Utils::Time.parse(date)
        @starts_at = Utils::Time.start_of_day(date_as_time)
        @ends_at = Utils::Time.end_of_day(date_as_time)
        @date = ::Date.new(@starts_at.year, @starts_at.month, @starts_at.day)

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
