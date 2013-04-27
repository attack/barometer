module Barometer
  module Response
    def self.new(metric=true)
      Barometer::Response::Base.new(metric)
    end
  end
end

require 'response/base'
require 'response/current'
require 'response/prediction'
require 'response/prediction_collection'
