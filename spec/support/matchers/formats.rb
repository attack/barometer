require 'rspec/expectations'

module Barometer
  module Matchers
    module Formats
      def is_of_format?(format, value)
        value.match(_find_regex(format))
      end

      def _find_regex(format)
        case format
        when :time
          /^\d{1,4}-\d{1,2}-\d{1,2} \d{2}:\d{2}:\d{2} [\-\+\d]{5}$/i
        when :optional_string
          /^[\w \.-]*$/i
        when :string
          /^[\w \.-]{2,}$/i
        when :number
          /^\d{1,3}$/i
        when :float
          /^[\d\.]{1,5}$/i
        when :temperature
          /^-?[0-9\.]{1,5}[ ]?[cfCF]?$/i
        when :pressure
          /^[0-9\.]{1,7}[ ]?[a-zA-Z]{0,3}$/i
        when :vector
          /^[0-9\.]{1,5} (?:mph|kph) (?:[nesw]{1,3}(?:orth|outh|t|ast)?|@ [0-9\.]{1,5} degrees)$/i
        when :distance
          /^[0-9\.]{1,5}[ ]?k?m?$/i
        when Regexp
          format
        end
      end
    end
  end
end
