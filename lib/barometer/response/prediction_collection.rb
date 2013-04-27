require 'date'

module Barometer
  module Response
    class PredictionCollection < Array
      def <<(value)
        raise ArgumentError unless value.is_a?(Response::Prediction)
        super(value)
      end

      def [](index)
        index.respond_to?(:to_i) ? super(index.to_i) : self.for(index)
      end

      def for(time)
        return nil unless size > 0

        time = case time
        when Date
          Time.utc(time.year,time.month,time.day,12,0,0)
        else
          Barometer::Utils::Time.parse(time)
        end

        detect { |forecast| forecast.covers?(time) }
      end
    end
  end
end
