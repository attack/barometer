module Barometer
  module Response
    def self.new
      Barometer::Response::Base.new
    end
  end
end

require 'barometer/response/base'
require 'barometer/response/current'
require 'barometer/response/prediction'
require 'barometer/response/prediction_collection'
