require 'ipaddr'

module Barometer
  module Query
    module Format
      #
      # eg. 8.8.8.8
      #
      class Ipv4Address < Base
        def self.is?(query)
          (ipaddr = IPAddr.new(query.to_s)) && ipaddr.ipv4?
        rescue ArgumentError
        end
      end
    end
  end
end

Barometer::Query::Format.register(:ipv4_address, Barometer::Query::Format::Ipv4Address)
