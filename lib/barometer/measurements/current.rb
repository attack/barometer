$:.unshift(File.dirname(__FILE__))
require 'utility/data_types'

module Barometer
  class Measurement::Current
    include Barometer::DataTypes

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
