require 'httpclient'

module Barometer
  module Http
    module Requester

      def self.get(address)
        http = HTTPClient.new
        http.receive_timeout = Barometer.timeout
        http.get(address).content
      rescue HTTPClient::TimeoutError
        raise Barometer::TimeoutError
      end

    end
  end
end
