require 'httpclient'

module Barometer
  module Utils
    class RedirectCallback
      def call(uri, res)
        newuri = HTTPClient::Util.urify(res.header['location'][0])
        if !http?(newuri) && !https?(newuri)
          newuri = uri + newuri
        end
        newuri
      end

      private

      def https?(uri)
        uri.scheme && uri.scheme.downcase == 'https'
      end

      def http?(uri)
        uri.scheme && uri.scheme.downcase == 'http'
      end
    end
  end
end
