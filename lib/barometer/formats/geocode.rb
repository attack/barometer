module Barometer
  #
  # Format: Geocode
  # (not to be confused with the WebService geocode)
  #
  # eg. 123 Elm St, Mystery, Alaska, USA
  #
  # This class is used to determine if a query is a
  # :geocode, how to convert to :geocode
  #
  class Query::Format::Geocode < Query::Format

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
        return (original_query.format == format ? original_query.dup : nil)
      end
      
      unless converted_query = original_query.get_conversion(format)
        converted_query = Barometer::Query.new
        converted_query = (original_query.format == :weather_id ?
         Query::Format::WeatherID.reverse(original_query) :
         geocode(original_query))
        original_query.post_conversion(converted_query) if converted_query
      end
      converted_query
    end

    # geocode the query
    #
    def self.geocode(original_query)
      raise ArgumentError unless is_a_query?(original_query)
      
      converted_query = Barometer::Query.new
      converted_query.geo = WebService::Geocode.fetch(original_query)
      if converted_query.geo
        converted_query.country_code = converted_query.geo.country_code
        converted_query.q = converted_query.geo.to_s
        converted_query.format = format
      end
      converted_query
    end

  end
end