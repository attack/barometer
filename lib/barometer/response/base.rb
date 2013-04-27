$:.unshift(File.dirname(__FILE__))
require 'utils/data_types'

module Barometer
  module Response
    class Base
      include Barometer::Utils::DataTypes

      location :location, :station
      timezone :timezone
      string :query
      integer :weight, :status_code
      symbol :source, :format
      time :response_started_at, :response_ended_at, :requested_at

      attr_accessor :current, :forecast

      def current
        @current
      end

      def initialize(metric=true)
        @metric = metric
        @weight = 1
        @current = Barometer::Response::Current.new
        @forecast = Barometer::Response::PredictionCollection.new
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
        forecast_result = Barometer::Response::Prediction.new
        yield(forecast_result)
        self.forecast << forecast_result
      end
    end
  end
end
