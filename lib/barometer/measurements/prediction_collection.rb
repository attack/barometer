require 'date'

module Barometer
  class Measurement::PredictionCollection < Array
    def <<(value)
      raise ArgumentError unless value.is_a?(Measurement::Prediction)
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
        Barometer::Helpers::Time.parse(time)
      end

      detect { |forecast| forecast.for_time?(time) }
    end
  end
end
