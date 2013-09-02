module Barometer
  module Response
    def self.new(query)
      Barometer::Response::Base.new(query)
    end
  end
end

require 'response/base'
require 'response/current'
require 'response/prediction'
require 'response/prediction_collection'
