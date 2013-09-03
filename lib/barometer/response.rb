module Barometer
  module Response
    def self.new(query)
      Barometer::Response::Base.new(query)
    end
  end
end

require 'barometer/response/base'
require 'barometer/response/current'
require 'barometer/response/prediction'
require 'barometer/response/prediction_collection'
