require 'virtus'

module Barometer
  module Data
    module Attribute
    end
  end
end

require_relative 'attributes/temperature.rb'
require_relative 'attributes/vector.rb'
require_relative 'attributes/pressure.rb'
require_relative 'attributes/distance.rb'
require_relative 'attributes/location.rb'
require_relative 'attributes/zone.rb'
require_relative 'attributes/sun.rb'
require_relative 'attributes/time.rb'
require_relative 'attributes/float.rb'
require_relative 'attributes/integer.rb'
