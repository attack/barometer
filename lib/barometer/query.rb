$:.unshift(File.dirname(__FILE__))
require 'query/base'

module Barometer
  ConvertedQuery = Struct.new(:q, :format, :country_code, :geo)

  module Query
    class ConversionNotPossible < StandardError; end
    class UnsupportedRegion < StandardError; end

    def self.new(query)
      Barometer::Query::Base.new(query)
    end
  end
end
