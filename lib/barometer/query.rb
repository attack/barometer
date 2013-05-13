$:.unshift(File.dirname(__FILE__))
require 'query/base'
require 'query/format'
require 'query/converter'
require 'query/service'

module Barometer
  ConvertedQuery = Struct.new(:q, :format, :geo)

  module Query
    class ConversionNotPossible < StandardError; end
    class UnsupportedRegion < StandardError; end

    def self.new(query)
      Barometer::Query::Base.new(query)
    end
  end
end
