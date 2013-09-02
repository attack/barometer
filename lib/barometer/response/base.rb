$:.unshift(File.dirname(__FILE__))
require 'utils/data_types'

module Barometer
  module Response
    class Base
      include Utils::DataTypes

      location :location, :station
      timezone :timezone
      string :query
      integer :weight, :status_code
      symbol :source, :format
      time :response_started_at, :response_ended_at, :requested_at

      attr_accessor :current, :forecast

      def initialize(query)
        @weight = 1
        @current = Current.new
        @forecast = PredictionCollection.new
        @requested_at = Time.now.utc
        add_query(query)
      end

      def success?
        status_code == 200
      end

      def complete?
        current && !current.temperature.nil?
      end

      def for(date=nil)
        forecast.for(date || today)
      end

      def build_forecast
        forecast_result = Prediction.new
        yield(forecast_result)
        self.forecast << forecast_result
      end

      def add_query(query)
        @query = query.q
        @format = query.format
        @metric = query.metric?
      end

      private

      def today
        timezone ? timezone.today : Date.today
      end
    end
  end
end
