require_relative 'apis/noaa_station'
require 'nokogiri'

module Barometer
  module Query
    module Service
      class NoaaStation
        def self.fetch(query)
          converted_query = query.get_conversion(:coordinates)
          return unless converted_query

          NoaaStation::Api.new(converted_query).get
        end
      end
    end
  end
end
