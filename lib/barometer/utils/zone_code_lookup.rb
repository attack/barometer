module Barometer
  module Utils
    class ZoneCodeLookup
      @@zone_codes_file = File.expand_path(
        File.join(File.dirname(__FILE__), 'translations', 'zone_codes.yml'))
      @@zone_codes = nil

      def self._load_zone_codes
        $:.unshift(File.dirname(__FILE__))
        @@zone_codes ||= YAML.load_file(@@zone_codes_file)
      end

      def self.exists?(code)
        _load_zone_codes unless @@zone_codes
        (::Time.zone_offset(code.to_s) || @@zone_codes && @@zone_codes.has_key?(code))
      end

      # Known conflicts:
      # IRT (ireland and india)
      # CST (central standard time, china standard time)
      #
      def self.offset(code)
        # http://www.timeanddate.com/library/abbreviations/timezones/
        # http://www.worldtimezone.com/wtz-names/timezonenames.html
        _load_zone_codes unless @@zone_codes
        ::Time.zone_offset(code) || ((@@zone_codes[code.to_s.upcase] || 0) * 60 * 60)
      end
    end
  end
end
