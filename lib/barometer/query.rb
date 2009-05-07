module Barometer
  #
  # This class represents a query and can answer the
  # questions that a Barometer will need to measure the weather
  #
  # Summary:
  #   When you create a new Query, you set the query string
  #   ie: "New York, NY" or "90210"
  #   The class will then determine the query string format
  #   ie: :zipcode, :postalcode, :geocode, :coordinates
  #   Now, when a Weather API driver asks for the query, it will prefer
  #   certain formats, and only permit certain formats.  The Query class
  #   will attempt to either return the query string as-is if acceptable,
  #   or it will attempt to convert it to a format that is acceptable
  #   (most likely this conversion will use Googles geocoding service using
  #   the Graticule gem).  Worst case scenario is that the Weather API will
  #   not accept the query string.
  #
  class Query
    
    # This array defines the order to check a query for the format
    #
    FORMATS = %w(
      ShortZipcode Zipcode Postalcode WeatherID Coordinates Icao Geocode
    )
    FORMAT_MAP = {
      :short_zipcode => "ShortZipcode", :zipcode => "Zipcode",
      :postalcode => "Postalcode", :weather_id => "WeatherID",
      :coordinates => "Coordinates", :icao => "Icao",
      :geocode => "Geocode"
    }
    
    attr_accessor :format, :q, :country_code, :geo
    
    def initialize(query=nil)
      return unless query
      @q = query
      self.analyze!
    end

    # analyze the saved query to determine the format.
    # this delegates the detection to each formats class
    # until th right one is found
    #
    def analyze!
      return unless @q
      FORMATS.each do |format|
        if Query::Format.const_get(format.to_s).is?(@q)
          @format = Query::Format.const_get(format.to_s).format
          @country_code = Query::Format.const_get(format.to_s).country_code(@q)
          break
        end
      end
    end
    
    # take a list of acceptable (and ordered by preference) formats and convert
    # the current query (q) into the most preferred and acceptable format. a
    # side effect of the conversions may reveal the country_code, if so save it
    #
    def convert!(preferred_formats=nil)
      raise ArgumentError unless (preferred_formats && preferred_formats.size > 0)
      
      # why convert if we are already there?
      skip_conversion = false
      if preferred_formats.include?(@format.to_sym)
        skip_conversion = true
        converted_query = self.dup
      end
      
      unless skip_conversion
        # go through each acceptable format and try to convert to that
        converted = false
        converted_query = Barometer::Query.new
        preferred_formats.each do |preferred_format|
          klass = FORMAT_MAP[preferred_format.to_sym]
          if preferred_format == @format
            converted = true
            converted_query = Barometer::Query.new(@q)
          end
          unless converted
            converted_query =  Query::Format.const_get(klass.to_s).to(self)
            converted = true if converted_query
          end
          if converted
            converted_query.country_code ||= Query::Format.const_get(klass.to_s).country_code(converted_query.q)
            break
          end
        end
      end
      
      # force geocode?, unless we already did
      #
      if Barometer.force_geocode && !@geo
        if converted_query && converted_query.geo
          @geo = converted_query.geo
        else
          geo_query = Query::Format::Coordinates.to(converted_query)
          @geo = geo_query.geo if (geo_query && geo_query.geo)
        end
      end
      
      converted_query
    end
    
  end
end  
