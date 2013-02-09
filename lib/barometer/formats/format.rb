module Barometer
  #
  # Base Format Class
  #
  # Fromats are used to determine if a query is of a certain
  # format, how to convert to and from that format
  # and what the country_code is for that format (if possible).
  # Some formats require external Web Services to help
  # in the converision. (ie :weather_id -> :geocode)
  #
  class Query::Format

    @@fixes_file = File.expand_path(
      File.join(File.dirname(__FILE__), '..', 'translations', 'weather_country_codes.yml'))
    @@fixes = nil

    # stubs
    #
    def self.regex; raise NotImplementedError; end
    def self.format; raise NotImplementedError; end

    # defaults
    #
    def self.to(query=nil,country=nil); nil; end
    def self.country_code(query=nil); nil; end
    def self.convertable_formats; []; end
    def self.convert_query(text); text; end

    # is the query of this format?
    #
    def self.is?(query=nil)
      raise ArgumentError unless query.is_a?(String)
      return !(query =~ self.regex).nil?
    end

    # does the format support conversion from the given query?
    #
    def self.converts?(query=nil)
      return false unless is_a_query?(query)
      self.convertable_formats.include?(query.format)
    end

    # is the object a Barometer::Query?
    #
    def self.is_a_query?(object=nil)
      return false unless object
      object.is_a?(Barometer::Query)
    end

    private

    # fix the country code
    #
    # weather.com uses non-standard two letter country codes that
    # hinder the ability to determine the country or fetch geo_data.
    # correct these "mistakes"
    #
    def self._fix_country(country_code)
      @@fixes ||= YAML.load_file(@@fixes_file)
      @@fixes[country_code.upcase.to_s] || country_code
    end

  end
end
