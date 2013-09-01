$:.unshift(File.dirname(__FILE__))
require 'query/base'
require 'query/format'
require 'query/converter'
require 'query/service'

module Barometer
  class ConvertedQuery
    attr_reader :q, :format, :units, :geo

    def initialize(q, format, units=:metric, geo=nil)
      @q = q
      @format = format
      @units = units
      @geo = geo
    end

    def metric?
      units == :metric
    end
  end

  module Query
    class ConversionNotPossible < StandardError; end
    class UnsupportedRegion < StandardError; end

    def self.new(*args)
      Barometer::Query::Base.new(*args)
    end
  end
end
