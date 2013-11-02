module Barometer
  module Query
    module Format
      #
      # Base Format Class
      #
      # Fromats are used to determine if a query is of a certain
      # format, how to convert to and from that format
      # and what the country_code is for that format (if possible).
      #
      class Base
        def self.regex; raise NotImplementedError; end
        def self.geo(query); nil; end
        def self.convert_query(query); query; end

        def self.is?(query)
          !(query =~ self.regex).nil?
        end
      end
    end
  end
end
