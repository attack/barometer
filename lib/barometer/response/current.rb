require 'barometer/utils/data_types'
require 'virtus'

module Barometer
  module Response
    class Current
      include Virtus
      include Utils::DataTypes

      attribute :temperature, Data::Attribute::Temperature
      attribute :dew_point, Data::Attribute::Temperature
      attribute :heat_index, Data::Attribute::Temperature
      attribute :wind_chill, Data::Attribute::Temperature
      attribute :wind, Data::Attribute::Vector
      attribute :pressure, Data::Attribute::Pressure
      attribute :humidity, Float, :writer_class => Data::FloatWriter
      attribute :icon, String
      attribute :condition, String

      time :observed_at, :stale_at
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
