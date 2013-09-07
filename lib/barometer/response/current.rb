require 'barometer/utils/data_types'
require 'virtus'

module Barometer
  module Response
    class Current
      include Virtus
      include Utils::DataTypes

      attribute :humidity, Float, :writer_class => Data::FloatWriter
      attribute :icon, String
      attribute :condition, String

      time :observed_at, :stale_at
      temperature :temperature, :dew_point, :heat_index, :wind_chill
      vector :wind
      pressure :pressure
      distance :visibility
      sun :sun

      def initialize(metric=true)
        @metric = metric
      end

      def complete?
        !temperature.nil?
      end
    end
  end
end
