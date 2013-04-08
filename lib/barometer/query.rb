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

    def initialize(query=nil)
      @q = query
      self.analyze!
      @conversions = {}
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

    def q
      format ? Barometer::Formats.find(format).convert_query(@q) : @q
    end

    def analyze!
      return unless @q
      Barometer::Formats.formats.each do |format_key, format_klass|
        if format_klass.is?(@q)
          @format = format_key
          @country_code = format_klass.country_code(@q)
          break
        end
      end
    end

    def convert!(*preferred_formats)
      return self if preferred_formats.include?(format)

      converters = Barometer::Converters.find_all(format, preferred_formats)

      conversion = nil
      Array(converters).each do |converter|
        conversion = converter.new(self).call
      end
      conversion || raise(Barometer::Query::ConversionNotPossible)
    end

    # def convert!(preferred_formats=nil)
    #   if Barometer.force_geocode && !@geo
    #     puts "enhance geocode: #{converted_query.q}" if Barometer::debug?
    #     geo_query = Query::Format::Coordinates.to(converted_query)
    #     @geo = geo_query.geo if (geo_query && geo_query.geo)
    #     converted_query.geo = @geo.dup
    #   end
    # end

    def latitude
      return nil unless self.format == :coordinates
      Query::Format::Coordinates.parse_latitude(self.q)
    end

    def longitude
      return nil unless self.format == :coordinates
      Query::Format::Coordinates.parse_longitude(self.q)
    end
  end
end
