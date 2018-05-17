require 'httpclient'

module Barometer
  module Utils
    module GetContent
      def self.call(url, query={})
        address = Barometer::Utils::Address.new(url, query)

        http = HTTPClient.new
        http.redirect_uri_callback = RedirectCallback.new
        http.receive_timeout = Barometer.timeout
        http.get_content(address)
      rescue HTTPClient::TimeoutError
        raise Barometer::TimeoutError
      end
    end
  end
end
