require 'rubygems'
require 'httparty'

$:.unshift(File.dirname(__FILE__))
# load some changes to Httparty
require 'extensions/httparty'

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
    
    # all service drivers will use the HTTParty gem
    include HTTParty
    
    POSSIBLE_FORMATS = %w(
      ShortZipcode Zipcode Postalcode WeatherID Coordinates Icao Geocode
    )
    DEFAULT_FORMAT = "Geocode"
    FORMAT_MAP = {
      :short_zipcode => "ShortZipcode", :zipcode => "Zipcode",
      :postalcode => "Postalcode", :weather_id => "WeatherID",
      :coordinates => "Coordinates", :icao => "Icao",
      :geocode => "Geocode"
    }
    
    attr_reader   :format
    attr_accessor :q, :preferred, :country_code, :geo
    
    def initialize(query=nil)
      @q = query
      self.analyze!
    end

    # analyze the saved query to determine the format.
    def analyze!
      return unless @q
      POSSIBLE_FORMATS.each do |format|
        if Barometer::Query.const_get(format.to_s).is?(@q)
          @format = Barometer::Query.const_get(format.to_s).format
          @country_code = Barometer::Query.const_get(format.to_s).country_code(@q)
          break
        end
      end
      unless @format
        @format = Barometer::Query.const_get(DEFAULT_FORMAT.to_s).format
      end
    end
    
    # take a list of acceptable (and ordered by preference) formats and convert
    # the current query (q) into the most preferred and acceptable format. as a
    # side effect of some conversions, the country_code might be known, then save it
    def convert!(preferred_formats=nil)
      raise ArgumentError unless (preferred_formats && preferred_formats.size > 0)
      @preferred = nil
      
      # go through each acceptable format and try to convert to that
      converted = false
      preferred_formats.each do |preferred_format|
        klass = FORMAT_MAP[preferred_format.to_sym]
        if preferred_format == @format
          converted = true
          @preferred ||= @q
        end
        unless converted
          @preferred, @country_code, @geo =  Barometer::Query.const_get(klass.to_s).to(@q, @format)
          converted = true if @preferred
        end
        @country_code ||= Barometer::Query.const_get(klass.to_s).country_code(@preferred) if converted
      end
      
      # if we haven't already geocoded and we are forcing it, do it now
      if !@geo && Barometer.force_geocode
        not_used_coords, not_used_code, @geo = Barometer::Query::Coordinates.to(@q, @format)
      end
      
      @preferred
    end
    
  end
end  
