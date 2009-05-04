module Barometer
  #
  # Coordinates Format
  #
  # eg: 123.1234,-123.123
  #
  class Query::Coordinates < Query::Format
  
    def self.regex
      /^[-]?[0-9\.]+[,]{1}[-]?[0-9\.]+$/
    end
  
    def self.format
      :coordinates
    end
  
    # make the given query of this format
    def self.to(current_query, current_format, current_country_code=nil)
  
      skip_formats = [:coordinates]
      return nil if skip_formats.include?(current_format)
      
      # treat special cases
      # this will convert the weather_id to a name, that can be further geocoded
      if current_format == :weather_id
        current_query = Barometer::Query::WeatherID.from(current_query)
      end
      
      geo = Barometer::Query::Geocode.geocode(current_query, current_country_code)
      current_country_code ||= geo.country_code if geo
      return nil unless geo && geo.longitude && geo.latitude
      ["#{geo.latitude},#{geo.longitude}", current_country_code, geo]
      
    end

  end
end