$:.unshift(File.dirname(__FILE__))
require 'utility/data_types'

module Barometer
  class Measurement::Prediction
    include Barometer::DataTypes

    time :starts_at, :ends_at
    temperature :high, :low
    float :pop
    string :icon, :condition
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

    def for_time?(time)
      raise ArgumentError unless time.is_a?(Time)
      time >= @starts_at && time <= @ends_at
    end
  end
end