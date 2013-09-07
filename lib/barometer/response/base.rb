require 'barometer/utils/data_types'
require 'virtus'

module Barometer
  module Response
    class Base
      include Virtus
      include Utils::DataTypes

      attribute :query, String

      location :location, :station
      timezone :timezone
      integer :weight, :status_code
      symbol :source, :format
      time :response_started_at, :response_ended_at, :requested_at

      attr_accessor :current, :forecast

      def initialize
        @weight = 1
        @requested_at = Time.now.utc
      end

      def success?
        status_code == 200
      end

      def complete?
        current && current.complete?
      end

      def for(date=nil)
        forecast.for(date || today)
      end

      def add_query(query)
        return unless query
        @query = query.to_s
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
