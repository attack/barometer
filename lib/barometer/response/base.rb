require 'virtus'

module Barometer
  module Response
    class Base
      include Virtus.model

      attribute :weight, Data::Attribute::Integer, default: 1
      attribute :status_code, Integer
      attribute :query, String
      attribute :location, Data::Attribute::Location
      attribute :station, Data::Attribute::Location
      attribute :timezone, Data::Attribute::Zone
      attribute :response_started_at, Data::Attribute::Time
      attribute :response_ended_at, Data::Attribute::Time
      attribute :requested_at, Data::Attribute::Time
      attribute :source, Symbol
      attribute :format, Symbol

      attr_accessor :current, :forecast

      def initialize
        super
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

      def metric?
        !!@metric
      end

      private

      def today
        timezone ? timezone.today : Date.today
      end
    end
  end
end
