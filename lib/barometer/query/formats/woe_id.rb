module Barometer
  module Query
    module Format
      #
      # WOEID: "Where on Earth" ID (by Yahoo!)
      # eg. 2459115, 615702 or w90210
      #
      # NOTE: zipcodes and WoeIDs can look exactly the same when the WoeID
      #   is 5 digits long.  For now, a 5 digit number will be detected as
      #   zipcode.  The way to override this is to prepend a number with the
      #   letter 'w'.  Therefore 90210 will be a zipcode and w90210 will be
      #   a WoeID.
      #
      class WoeID < Base
        def self.regex; /(^[0-9]{4}$)|(^[0-9]{6,7}$)|(^w[0-9]{4,7}$)/; end

        # remove the 'w' from applicable queries (only needed for detection)
        #
        def self.convert_query(text)
          return nil unless text
          text.delete('w')
        end
      end
    end
  end
end

Barometer::Query::Format.register(:woe_id, Barometer::Query::Format::WoeID)
