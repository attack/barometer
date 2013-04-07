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
  ConvertedQuery = Struct.new(:q, :format, :country_code, :geo, :latitude, :longitude)

  class Query
    class ConversionNotPossible < StandardError; end
    class UnsupportedRegion < StandardError; end

    class NotFound < StandardError; end

    @@formats = []

    def self.formats=(formats)
      @@formats = formats
    end

    def self.formats
      @@formats
    end

    def self.register(key, format)
      @@formats ||= []
      @@formats << [ key.to_sym, format ] unless has?(key)
    end

    def self.has?(key)
      !@@formats.select{|format| format[0] == key.to_sym}.empty?
    end

    def self.find(key)
      @@formats ||= []
      format = @@formats.select{|format| format[0] == key.to_sym}

      if format && format[0]
        format[0][1]
      else
        raise NotFound
      end
    end

    def add_conversion(key, value)
      @conversions ||= {}
      @conversions[key] = value
      Barometer::ConvertedQuery.new(value, key, country_code, geo, latitude, longitude)
    end

    def get_conversion(*formats)
      format_to_return = formats.detect{|f| format == f || @conversions.has_key?(f)}
      puts "found: #{self.format} -> #{format_to_return} = #{self.q} -> #{@conversions[format_to_return]}" if Barometer::debug? && format_to_return
      if format_to_return == format
        Barometer::ConvertedQuery.new(q, format, country_code, geo, latitude, longitude)
      else
        Barometer::ConvertedQuery.new(@conversions[format_to_return], format_to_return, country_code, geo, latitude, longitude) if format_to_return
      end
    end

    attr_writer :q
    attr_accessor :format, :country_code
    attr_accessor :geo, :timezone, :conversions

    def initialize(query=nil)
      return unless query
      @q = query
      self.analyze!
      @conversions = {}
    end

    def q
      format ? Barometer::Query.find(format).convert_query(@q) : @q
    end

    # analyze the saved query to determine the format.
    # this delegates the detection to each formats class
    # until th right one is found
    #
    def analyze!
      return unless @q
      @@formats.each do |format|
        if format[1].is?(@q)
          @format = format[0]
          @country_code = format[1].country_code(@q)
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
          klass = Barometer::Query.find(preferred_format)
          # if we discover that the format we have is the preferred format, return it
          if preferred_format == @format
            converted = true
            converted_query = Barometer::Query.new(@q)
          end
          unless converted
            unless converted_query = get_conversion(preferred_format)
              converted_query = klass.to(self)
            end
            converted = true if converted_query
          end
          if converted
            converted_query.country_code ||= klass.country_code(converted_query.q)
            post_conversion(converted_query)
            break
          end
        end

        raise ConversionNotPossible unless converted
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

  def latitude
    return nil unless self.format == Query::Format::Coordinates.format
    Query::Format::Coordinates.parse_latitude(self.q)
  end

  def longitude
    return nil unless self.format == Query::Format::Coordinates.format
    Query::Format::Coordinates.parse_longitude(self.q)
  end

  end
end
