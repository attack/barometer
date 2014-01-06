require 'delegate'
require 'choc_mool'

module Barometer
  module Utils
    class Payload < SimpleDelegator
      attr_reader :query

      def initialize(hash, query=nil)
        @query = query
        super( ChocMool.new(hash) )
      end

      def units
        query.units if query
      end
    end
  end
end
