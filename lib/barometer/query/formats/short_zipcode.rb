module Barometer
  module Query
    module Format
      #
      # eg. 90210
      #
      class ShortZipcode < Base
        def self.country_code(query); "US"; end
        def self.regex; /(^[0-9]{5}$)/; end
      end
    end
  end
end

Barometer::Query::Format.register(:short_zipcode, Barometer::Query::Format::ShortZipcode)
