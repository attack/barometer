module Barometer
  module Http
    module Get
      def self.call(url, query={})
        address = Barometer::Http::Address.new(url, query)
        Barometer::Http::Requester.get(address)
      end
    end
  end
end
