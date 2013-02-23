require 'date'

module Barometer
  class Measurement::ResultArray < Array
    def <<(value)
      raise ArgumentError unless value.is_a?(Measurement::Result)
      super(value)
    end

    def [](index)
      index.respond_to?(:to_i) ? super(index.to_i) : self.for(index)
    end

    def for(datetime)
      return nil unless size > 0

      datetime = case datetime
      when Date
        Data::LocalDateTime.new(datetime.year,datetime.month,datetime.day,12,0,0)
      else
        Data::LocalDateTime.parse(datetime)
      end

      detect { |forecast| forecast.for_datetime?(datetime) }
    end
  end
end
