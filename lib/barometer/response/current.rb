$:.unshift(File.dirname(__FILE__))
require 'utils/data_types'

module Barometer
  module Response
    class Current
      include Barometer::Utils::DataTypes

      time :observed_at, :stale_at
      temperature :temperature, :dew_point, :heat_index, :wind_chill
      vector :wind
      pressure :pressure
      distance :visibility
      float :humidity
      string :icon, :condition
      sun :sun

      def initialize(metric=true)
        @metric = metric
      end
    end
  end
end
