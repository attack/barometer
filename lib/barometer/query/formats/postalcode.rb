module Barometer
  module Query
    module Format
      #
      # eg. H0H 0H0
      #
      class Postalcode < Base
        def self.geo(query); {country_code: 'CA'}; end
        def self.regex
          # Rules: no D, F, I, O, Q, or U anywhere
          # Basic validation: ^[ABCEGHJ-NPRSTVXY]{1}[0-9]{1}[ABCEGHJ-NPRSTV-Z]{1}
          #   [ ]?[0-9]{1}[ABCEGHJ-NPRSTV-Z]{1}[0-9]{1}$
          /^[A-Z]{1}[\d]{1}[A-Z]{1}[ ]?[\d]{1}[A-Z]{1}[\d]{1}$/
        end
      end
    end
  end
end

Barometer::Query::Format.register(:postalcode, Barometer::Query::Format::Postalcode)
