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
    
    attr_accessor :format, :q, :country_code
    attr_accessor :geo, :timezone, :conversions
    
    def initialize(query=nil)
      return unless query
      @q = query
      self.analyze!
      @conversions = {}
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
      # (except in the case that the serivce excepts coordinates and we have a
      # a geocode ... the google geocode results are superior)
      #
      skip_conversion = false
      unless (@format.to_sym == Query::Format::Geocode.format) &&
             preferred_formats.include?(Query::Format::Coordinates.format)
        if preferred_formats.include?(@format.to_sym)
          skip_conversion = true
          converted_query = self.dup
        end
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
            unless converted_query = get_conversion(preferred_format)
              converted_query =  Query::Format.const_get(klass.to_s).to(self)
            end  
            converted = true if converted_query
          end
          if converted
            converted_query.country_code ||= Query::Format.const_get(klass.to_s).country_code(converted_query.q)
            post_conversion(converted_query)
            break
          end
        end
      end
      
      # force geocode?, unless we already did
      #
      if Barometer.force_geocode && !@geo
        if converted_query && converted_query.geo
          @geo = converted_query.geo
        elsif converted_query
          puts "enhance geocode: #{converted_query.q}" if Barometer::debug?
          geo_query = Query::Format::Coordinates.to(converted_query)
          @geo = geo_query.geo if (geo_query && geo_query.geo)
          converted_query.geo = @geo.dup
        end
      end
      
      # enhance timezone?, unless we already did
      #
      if Barometer.enhance_timezone && !@timezone
        if converted_query && converted_query.timezone
          @geo = converted_query.timezone
        elsif @geo && @geo.latitude && @geo.longitude
          puts "enhance timezone: #{@geo.latitude}, #{@geo.longitude}" if Barometer::debug?
          @timezone = WebService::Timezone.fetch(@geo.latitude,@geo.longitude)
          converted_query.timezone = @timezone.dup
        end
      end
      
      converted_query
    end
    
# save the important parts of the conversion ... by saving conversion we
# can avoid doing the same conversion multiple times
#
def post_conversion(converted_query)
  return unless (converted_query && converted_query.q && converted_query.format)
  @conversions = {} unless @conversions
  return if @conversions.has_key?(converted_query.format.to_sym)
  puts "store: #{self.format} -> #{converted_query.format.to_sym} = #{self.q} -> #{converted_query.q}" if Barometer::debug?
  @conversions[converted_query.format.to_sym] = converted_query.q
end

def get_conversion(format)
  return nil unless format && @conversions
  puts "found: #{self.format} -> #{format.to_sym} = #{self.q} -> #{@conversions[format.to_sym]}" if Barometer::debug? && @conversions.has_key?(format.to_sym)
  # re-constuct converted query
  if q = @conversions[format.to_sym]
    converted_query = self.dup
    converted_query.q = q
    converted_query.format = format
    converted_query
  else
    nil
  end
end
    
  end
end  
