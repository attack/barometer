module Barometer
  #
  # Format: Geocode
  #
  # eg. 123 Elm St, Mystery, Alaska, USA
  #
  # This class is used to determine if a query is a
  # :geocode, how to convert to :geocode
  #
  class Query::Geocode < Query::Format

    def self.format; :geocode; end
    def self.is?(query=nil); query.is_a?(String) ? true : false; end
    def self.convertable_formats
      [:short_zipcode, :zipcode, :coordinates, :weather_id, :icao]
    end

    # convert to this format, X -> :geocode
    #
    def self.to(original_query)
      raise ArgumentError unless is_a_query?(original_query)
      unless converts?(original_query)
        return (original_query.format == format ? original_query : nil)
      end
      converted_query = Barometer::Query.new
    
      converted_query = (original_query.format == :weather_id ?
        Barometer::Query::WeatherID.reverse(original_query) :
        geocode(original_query))
      converted_query
    end

    # geocode the query
    #
    def self.geocode(original_query)
      raise ArgumentError unless is_a_query?(original_query)
      converted_query = Barometer::Query.new

      converted_query.geo = _geocode(original_query)
      if converted_query.geo
        converted_query.country_code = converted_query.geo.country_code
        converted_query.q = converted_query.geo.to_s
        converted_query.format = format
      end
      converted_query
    end

    private

    def self._has_geocode_key?
      !Barometer.google_geocode_key.nil?
    end

    def self._geocode(query)
      raise ArgumentError unless is_a_query?(query)
      return nil unless _has_geocode_key?
      location = Barometer::Query.get(
        "http://maps.google.com/maps/geo",
        :query => {
          :gl => query.country_code, :key => Barometer.google_geocode_key,
          :output => "xml", :q => query.q
        },
        :format => :xml, :timeout => Barometer.timeout
      )
      location = location['kml']['Response'] if location && location['kml']
      location ? (geo = Data::Geo.new(location)) : nil
    end
    
  end
end

