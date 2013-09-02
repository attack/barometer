require 'date'

module Barometer
  module Response
    class PredictionCollection
      include Enumerable

      def initialize(*predictions)
        @predictions = predictions
      end

      def each(&block)
        @predictions.each(&block)
      end

      def <<(prediction)
        @predictions << prediction
      end

      def [](index)
        index.respond_to?(:to_i) ? @predictions[index] : self.for(index)
      end

      def size
        @predictions.size
      end

      def for(time)
        return nil unless size > 0

        time = case time
        when Date
          Time.utc(time.year,time.month,time.day,12,0,0)
        else
          Utils::Time.parse(time)
        end

        detect{ |forecast| forecast.covers?(time) }
      end

      def build
        prediction = Prediction.new
        yield(prediction)
        @predictions << prediction
      end
    end
  end
end
