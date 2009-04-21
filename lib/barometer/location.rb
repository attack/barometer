module Barometer
  #
  # This class represents a location and can answer the
  # questions that a Barometer will need to measure the weather
  # 
  # You need to have a location before you can use a barometer, so you
  # actually measure the weather from the location object
  #
  # 
  # Summary:
  #   When you create a new Location, you set the location query string
  #   ie: "New York, NY" or "90210"
  #   The class will then determine the query string format
  #   ie: :zipcode, :postalcode, :geocode, :coordinates
  #   Now, when a Weather API driver asks for the location, it will prefer
  #   certain formats, and only permit certain formats.  The Location class
  #   will attempt to either return the query string as-is if acceptable,
  #   or it will attempt to convert it to a format that is acceptable
  #   (most likely this conversion will in Googles geocoding service using
  #   the Graticule gem).  Worst case scenario is that the Weather API will
  #   not accept the query string.
  #
  class Location
    
    # OPTIONAL
    # used by Graticule for geocoding
    @@google_api_key = nil
    def self.google_api_key; @@google_api_key; end;
    def self.google_api_key=(key); @@google_api_key = key; end;
    
    attr_reader   :format, :preffered_query
    attr_accessor :query
    
    def initialize(query=nil)
      @query = query
      self.determine_format!
      
      # DEVELOPMENT FEEDBACK
      # puts "Location: the query '#{@query}' is of format '#{@format.to_s}'"
    end
    
    def determine_format!
      return unless @query
      if Barometer::Location.is_zipcode?(@query)
        @format = :zipcode
      elsif Barometer::Location.is_canadian_postcode?(@query)
        @format = :postalcode
      elsif Barometer::Location.is_coordinates?(@query)
        @format = :coordinates
      else
        @format = :geocode
      end
    end
    
    def convert_query!(preffered_formats=nil)
      raise StandardError unless (preffered_formats && preffered_formats.size > 0)

      # first off, if the format we currently have is in the list, just use that
      return (@preffered_query = @query) if preffered_formats.include?(@format)
      
      # some formats do not convert, so raise an error (or just exit)
      #non_converting_formats = []
      #return (@preffered_query = nil) if
      #  non_converting_formats && non_converting_formats.include?(@format)
      
      # looks like we will have to attempt converting the query
      # go through each acceptable format and try to convert to that
      preffered_formats.each do |preffered_format|
        case preffered_format
        when :coordinates
          @preffered_query = Barometer::Location.to_coordinates(@query, @format)
        when :geocode
          @preffered_query = Barometer::Location.to_geocode(@query, @format)
        end
      end
      
      @preffered_query || nil
    end
    
    # def optimize_query!(preffered_formats = [:geocode])
    #    
    #   # looks like we will have to attempt converting the query
    #   # go through each acceptable format and try to convert to that
    #   preffered_formats.each do |preffered_format|
    #     case preffered_format
    #     when :coordinates
    #       @preffered_query = Barometer::Location.to_coordinates(@query, @format)
    #       return @preffered_query if @preffered_query
    #     when :geocode
    #       @preffered_query = Barometer::Location.to_geocode(@query, @format)
    #       return @preffered_query if @preffered_query
    #     end
    #   end
    #   
    #   # if we got this far then nothing could be converted
    #   return (@preffered_query = nil)
    # end
    
    #
    # HELPERS
    #
    
    def zipcode?
      @format == :zipcode
    end
    
    def postalcode?
      @format == :postalcode
    end

    def coordinates?
      @format == :coordinates
    end

    def geocode?
      @format == :geocode
    end
    
    def self.is_zipcode?(query)
      us_zipcode_regex = /(^[0-9]{5}$)|(^[0-9]{5}-[0-9]{4}$)/
      return !(query =~ us_zipcode_regex).nil?
    end
    
    def self.is_canadian_postcode?(query)
      # Rules: no D, F, I, O, Q, or U anywhere
      # Basic validation: ^[ABCEGHJ-NPRSTVXY]{1}[0-9]{1}[ABCEGHJ-NPRSTV-Z]{1}[ ]?[0-9]{1}[ABCEGHJ-NPRSTV-Z]{1}[0-9]{1}$
      # Extended validation: ^(A(0[ABCEGHJ-NPR]|1[ABCEGHK-NSV-Y]|2[ABHNV]|5[A]|8[A])|B(0[CEHJ-NPRSTVW]|1[ABCEGHJ-NPRSTV-Y]|2[ABCEGHJNRSTV-Z]|3[ABEGHJ-NPRSTVZ]|4[ABCEGHNPRV]|5[A]|6[L]|9[A])|C(0[AB]|1[ABCEN])|E(1[ABCEGHJNVWX]|2[AEGHJ-NPRSV]|3[ABCELNVYZ]|4[ABCEGHJ-NPRSTV-Z]|5[ABCEGHJ-NPRSTV]|6[ABCEGHJKL]|7[ABCEGHJ-NP]|8[ABCEGJ-NPRST]|9[ABCEGH])|G(0[ACEGHJ-NPRSTV-Z]|1[ABCEGHJ-NPRSTV-Y]|2[ABCEGJ-N]|3[ABCEGHJ-NZ]|4[ARSTVWXZ]|5[ABCHJLMNRTVXYZ]|6[ABCEGHJKLPRSTVWXZ]|7[ABGHJKNPSTXYZ]|8[ABCEGHJ-NPTVWYZ]|9[ABCHNPRTX])|H(0[HM]|1[ABCEGHJ-NPRSTV-Z]|2[ABCEGHJ-NPRSTV-Z]|3[ABCEGHJ-NPRSTV-Z]|4[ABCEGHJ-NPRSTV-Z]|5[AB]|7[ABCEGHJ-NPRSTV-Y]|8[NPRSTYZ]|9[ABCEGHJKPRSWX])|J(0[ABCEGHJ-NPRSTV-Z]|1[ACEGHJ-NRSTXZ]|2[ABCEGHJ-NRSTWXY]|3[ABEGHLMNPRTVXYZ]|4[BGHJ-NPRSTV-Z]|5[ABCJ-MRTV-Z]|6[AEJKNRSTVWYXZ]|7[ABCEGHJ-NPRTV-Z]|8[ABCEGHLMNPRTVXYZ]|9[ABEHJLNTVXYZ])|K(0[ABCEGHJ-M]|1[ABCEGHJ-NPRSTV-Z]|2[ABCEGHJ-MPRSTVW]|4[ABCKMPR]|6[AHJKTV]|7[ACGHK-NPRSV]|8[ABHNPRV]|9[AHJKLV])|L(0[[ABCEGHJ-NPRS]]|1[ABCEGHJ-NPRSTV-Z]|2[AEGHJMNPRSTVW]|3[BCKMPRSTVXYZ]|4[ABCEGHJ-NPRSTV-Z]|5[ABCEGHJ-NPRSTVW]|6[ABCEGHJ-MPRSTV-Z]|7[ABCEGJ-NPRST]|8[EGHJ-NPRSTVW]|9[ABCGHK-NPRSTVWYZ])|M(1[BCEGHJ-NPRSTVWX]|2[HJ-NPR]|3[ABCHJ-N]|4[ABCEGHJ-NPRSTV-Y]|5[ABCEGHJ-NPRSTVWX]|6[ABCEGHJ-NPRS]|7[AY]|8[V-Z]|9[ABCLMNPRVW])|N(0[ABCEGHJ-NPR]|1[ACEGHKLMPRST]|2[ABCEGHJ-NPRTVZ]|3[ABCEHLPRSTVWY]|4[BGKLNSTVWXZ]|5[ACHLPRV-Z]|6[ABCEGHJ-NP]|7[AGLMSTVWX]|8[AHMNPRSTV-Y]|9[ABCEGHJKVY])|P(0[ABCEGHJ-NPRSTV-Y]|1[ABCHLP]|2[ABN]|3[ABCEGLNPY]|4[NPR]|5[AEN]|6[ABC]|7[ABCEGJKL]|8[NT]|9[AN])|R(0[ABCEGHJ-M]|1[ABN]|2[CEGHJ-NPRV-Y]|3[ABCEGHJ-NPRSTV-Y]|4[AHJKL]|5[AGH]|6[MW]|7[ABCN]|8[AN]|9[A])|S(0[ACEGHJ-NP]|2[V]|3[N]|4[AHLNPRSTV-Z]|6[HJKVWX]|7[HJ-NPRSTVW]|9[AHVX])|T(0[ABCEGHJ-MPV]|1[ABCGHJ-MPRSV-Y]|2[ABCEGHJ-NPRSTV-Z]|3[ABCEGHJ-NPRZ]|4[ABCEGHJLNPRSTVX]|5[ABCEGHJ-NPRSTV-Z]|6[ABCEGHJ-NPRSTVWX]|7[AENPSVXYZ]|8[ABCEGHLNRSVWX]|9[ACEGHJKMNSVWX])|V(0[ABCEGHJ-NPRSTVWX]|1[ABCEGHJ-NPRSTV-Z]|2[ABCEGHJ-NPRSTV-Z]|3[ABCEGHJ-NRSTV-Y]|4[ABCEGK-NPRSTVWXZ]|5[ABCEGHJ-NPRSTV-Z]|6[ABCEGHJ-NPRSTV-Z]|7[ABCEGHJ-NPRSTV-Y]|8[ABCGJ-NPRSTV-Z]|9[ABCEGHJ-NPRSTV-Z])|X(0[ABCGX]|1[A])|Y(0[AB]|1[A]))[ ]?[0-9]{1}[ABCEGHJ-NPRSTV-Z]{1}[0-9]{1}$
      ca_postcode_regex = /^[A-Z]{1}[\d]{1}[A-Z]{1}[ ]?[\d]{1}[A-Z]{1}[\d]{1}$/
      return !(query =~ ca_postcode_regex).nil?
    end

    def self.is_coordinates?(query)
      coordinates_regex = /^[-]?[0-9\.]+[,]{1}[-]?[0-9\.]+$/
      return !(query =~ coordinates_regex).nil?
    end
    
    #
    # CONVERTERS
    #
    
    # this will take all query formats and convert them to coorinates
    # accepts- :zipcode, :postalcode, :geocode
    # returns- :coordinates
    def self.to_coordinates(query, format)
      # quick check to see that the Google API key used by Graticule exists
      return nil unless (self.google_api_key && !self.google_api_key.nil?)
      
      # attempt to load Graticule
      begin
        require 'rubygems'
        require 'graticule'
        $:.unshift(File.dirname(__FILE__))
        # load some changes to Graticule
        # TODO: attempt to get changes into Graticule gem
        require 'extensions/graticule'
      rescue LoadError
        return nil
      end
      
      # Google via Graticule will accept a country code to bias the results
      case format
      when :zipcode
        country_code = "US"
      when :postalcode
        country_code = "CA"
      else
        country_code = nil
      end
      
      geocoder = Graticule.service(:google).new(self.google_api_key)
      location = geocoder.locate(query, country_code)
      
      # return coordinates
      return nil unless location && location.longitude && location.latitude
      "#{location.latitude},#{location.longitude}"
    end
    
    # this will take all query formats and convert them to coorinates
    # accepts- :zipcode, :postalcode, :coordinates
    # returns- :geocode
    def self.to_geocode(query, format)
      use_graticule = false
      # quick check to see that the Google API key used by Graticule exists
      use_graticule = true if (self.google_api_key && !self.google_api_key.nil?)
      
      # some formats can't convert, no need to use Graticule
      skip_formats = [:postalcode]
      use_graticule = false if skip_formats.include?(format)
      
      # attempt to load Graticule
      if use_graticule
        begin
          require 'rubygems'
          require 'graticule'
          $:.unshift(File.dirname(__FILE__))
          # load some changes to Graticule
          # TODO: attempt to get changes into Graticule gem
          require 'extensions/graticule'
        rescue LoadError
          use_graticule = false
        end
      end
      
      if use_graticule
        # Google via Graticule will accept a country code to bias the results
        case format
        when :zipcode
          country_code = "US"
        when :postalcode
          country_code = "CA"
        else
          country_code = nil
        end
      
        geocoder = Graticule.service(:google).new(self.google_api_key)
        location = geocoder.locate(query, country_code)
      
        # return geocode
        return nil unless location && location.locality && location.region && location.country
        return "#{location.locality}, #{location.region}, #{location.country}"
      else
        # without geocoding, the best we can do is just make use the given query as
        # the query for the "geocode" format
        return query
      end
      return nil
    end

  end
end  
