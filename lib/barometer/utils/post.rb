require 'httpclient'

module Barometer
  module Utils
    module Post
      def self.call(url, params={})
        http = HTTPClient.new
        http.receive_timeout = Barometer.timeout
        http.post(url, default_params.merge(params)).content
      rescue HTTPClient::TimeoutError
        raise Barometer::TimeoutError
      end

      private

      def self.default_params
        {
          documentType: 'text/html',
          outputType: 'xml'
        }
      end
    end
  end
end
