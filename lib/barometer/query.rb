require_relative 'query/base'
require_relative 'query/format'
require_relative 'query/converter'
require_relative 'query/service'

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

    def to_s
      @q
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
