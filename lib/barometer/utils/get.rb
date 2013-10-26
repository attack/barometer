require 'httpclient'

module Barometer
  module Utils
    module Get
      def self.call(url, query={})
        address = Barometer::Utils::Address.new(url, query)

        http = HTTPClient.new
        http.receive_timeout = Barometer.timeout
        http.get(address)
      rescue HTTPClient::TimeoutError
        raise Barometer::TimeoutError
      end
    end
  end
end
