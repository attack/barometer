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
      attribute :visibility, Data::Attribute::Distance
      attribute :humidity, Data::Attribute::Float
      attribute :icon, String
      attribute :condition, String

      time :observed_at, :stale_at
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
