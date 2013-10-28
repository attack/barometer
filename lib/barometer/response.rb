module Barometer
  module Response
    def self.new
      Barometer::Response::Base.new
    end
  end
end

require_relative 'response/base'
require_relative 'response/current'
require_relative 'response/prediction'
require_relative 'response/prediction_collection'
