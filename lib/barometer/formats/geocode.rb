module Barometer
  #
  # Geocode Format
  #
  # eg. 123 Elm St, Mystery, Alaska, USA
  #
  class Query::Geocode < Query::Format
  
    def self.format; :geocode; end

    # everything is a geocode (if it is a String)
    def self.is?(query=nil)
      query.is_a?(String) ? true : false
    end
  
    # convert to this format
    def self.to(current_query, current_format, current_country_code=nil)
      perform_geocode = _has_geocode_key?

      skip_formats = [:postalcode]
      return [current_query,current_country_code,nil] if skip_formats.include?(current_format)
      
      # treat special cases
      # this will convert the weather_id to a name, that can be further geocoded
      if current_format == :weather_id
        current_query = Barometer::Query::WeatherID.from(current_query)
      end
      
      if perform_geocode
        geo = self.geocode(current_query, current_country_code)
        current_country_code ||= geo.country_code if geo
        # different formats have different acceptance criteria
        q = current_query
        case current_format
        when :icao
          if geo && geo.address && geo.country
            q = "#{geo.address}, #{geo.country}"
          end
        else
          if geo && geo.locality && geo.region && geo.country
            q = "#{geo.locality}, #{geo.region}, #{geo.country}"
          end
        end
        return [q, current_country_code, geo]
      else
        # without geocoding, the best we can do is just make use the given query as
        # the query for the "geocode" format
        return [current_query, current_country_code, nil]
      end
    end
    
    def self.geocode(query, country_code=nil)
      _geocode_httparty(query, country_code)
    end

    private
    
    def self._has_geocode_key?
      !Barometer.google_geocode_key.nil?
    end
    
    def self._geocode_httparty(query, country_code=nil)
      return nil unless _has_geocode_key?
      location = Barometer::Query.get(
        "http://maps.google.com/maps/geo",
        :query => {
          :gl => country_code,
          :key => Barometer.google_geocode_key,
          :output => "xml",
          :q => query
        },
        :format => :xml,
        :timeout => Barometer.timeout
      )
      location = location['kml']['Response'] if location && location['kml']
      location ? (geo = Data::Geo.new(location)) : nil
    end
    
  end
end

