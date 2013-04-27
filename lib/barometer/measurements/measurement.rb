$:.unshift(File.dirname(__FILE__))
require 'utils/data_types'

module Barometer
  class Measurement
    include Barometer::Utils::DataTypes

    location :location, :station
    timezone :timezone
    string :query
    integer :weight, :status_code
    symbol :source, :format
    time :measurement_started_at, :measurement_ended_at, :requested_at

    attr_accessor :current, :forecast

    def current
      @current
    end

    def initialize(metric=true)
      @metric = metric
      @weight = 1
      @current = Barometer::Measurement::Current.new
      @forecast = Barometer::Measurement::PredictionCollection.new
      @requested_at = Time.now.utc
    end

    def success?
      status_code == 200
    end

    def complete?
      current && !current.temperature.nil?
    end

    def now
      timezone ? timezone.now : nil
    end

    def for(date=nil)
      date = @timezone.today unless date || !@timezone
      date ||= Date.today
      return nil unless (@forecast && @forecast.size > 0)

      forecast = @forecast.for(date)
      forecast
    end

    def build_forecast
      forecast_result = Barometer::Measurement::Prediction.new
      yield(forecast_result)
      self.forecast << forecast_result
    end
  end
end
