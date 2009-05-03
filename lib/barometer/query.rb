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
  #   (most likely this conversion will in Googles geocoding service using
  #   the Graticule gem).  Worst case scenario is that the Weather API will
  #   not accept the query string.
  #
  class Query
    
    # OPTIONAL: key required by Google for geocoding
    @@google_geocode_key = nil
    def self.google_geocode_key; @@google_geocode_key || Barometer.google_geocode_key; end;
    def self.google_geocode_key=(key); @@google_geocode_key = key; end;
    
    attr_reader   :format
    attr_accessor :q, :preferred, :country_code, :geo
    
    def initialize(query=nil)
      @q = query
      self.analyze!
    end
    
    # analyze the saved query to determine the format.
    def analyze!
      return unless @q
      if Barometer::Query.is_us_zipcode?(@q)
        @format = :zipcode
        @country_code = Barometer::Query.format_to_country_code(@format)
      elsif Barometer::Query.is_canadian_postcode?(@q)
        @format = :postalcode
        @country_code = Barometer::Query.format_to_country_code(@format)
      elsif Barometer::Query.is_coordinates?(@q)
        @format = :coordinates
      elsif Barometer::Query.is_icao?(@q)
        @format = :icao
#        @country_code = Barometer::Query.icao_to_country_code(@q)
      else
        @format = :geocode
      end
    end
    
    # take a list of acceptable (and ordered by preference) formats and convert
    # the current query (q) into the most preferred and acceptable format. as a
    # side effect of some conversions, the country_code might be known, then save it
    def convert!(preferred_formats=nil)
      raise ArgumentError unless (preferred_formats && preferred_formats.size > 0)
      # reset preferred
      @preferred = nil
      
      # go through each acceptable format and try to convert to that
      converted = false
      geocoded = false
      preferred_formats.each do |preferred_format|
        # we are already in this format, return this
        if preferred_format == @format
          converted = true
          @preferred ||= @q
        end
        
        unless converted
          case preferred_format
          when :coordinates
            geocoded = true
            @preferred, @country_code, @geo = Barometer::Query.to_coordinates(@q, @format)
          when :geocode
            geocoded = true
            @preferred, @country_code, @geo = Barometer::Query.to_geocode(@q, @format)
          end
        end
      end
      
      # if we haven't already geocoded and we are forcing it, do it now
      if !geocoded && Barometer.force_geocode
        not_used_coords, not_used_code, @geo = Barometer::Query.to_coordinates(@q, @format)
      end
      
      @preferred
    end
    
    #
    # HELPERS
    #
    
    def zipcode?; @format == :zipcode; end
    def postalcode?; @format == :postalcode; end
    def coordinates?; @format == :coordinates; end
    def geocode?; @format == :geocode; end
    def icao?; @format == :icao; end
    
    def self.is_us_zipcode?(query)
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
    
    def self.is_icao?(query)
      # allow any 3 or 4 letter word ... unfortunately this means some locations
      # (ie Utah, Goa, Kiev, etc) will be detected as ICAO.  This won't matter for
      # returning weather results ... it will just effect what happens to the query.
      # For example, wunderground will accept :icao above :coordinates and :geocode,
      # which means that a city like Kiev would normally get converted to :coordinates
      # but in this case it will be detected as :icao so it will be passed as is.
      # Currently, only wunderground accepts ICAO, and they process ICAO the same as a
      # city name, so it doesn't matter.
      icao_regex = /^[A-Za-z]{3,4}$/
      return !(query =~ icao_regex).nil?
    end
    
    #
    # CONVERTERS
    #
    
    # this will take all query formats and convert them to coordinates
    # accepts- :zipcode, :postalcode, :geocode, :icao
    # returns- :coordinates
    # if the conversion fails, return nil
    def self.to_coordinates(query, format)
      country_code = self.format_to_country_code(format)
      geo = self.geocode(query, country_code)
      country_code ||= geo.country_code if geo
      return nil unless geo && geo.longitude && geo.latitude
      ["#{geo.latitude},#{geo.longitude}", country_code, geo]
    end
    
    # this will take all query formats and convert them to coorinates
    # accepts- :zipcode, :postalcode, :coordinates, :icao
    # returns- :geocode
    def self.to_geocode(query, format)
      perform_geocode = false
      perform_geocode = true if self.has_geocode_key?
      
      # some formats can't convert, no need to geocode then
      skip_formats = [:postalcode]
      perform_geocode = false if skip_formats.include?(format)
      
      country_code = self.format_to_country_code(format)
      if perform_geocode
        geo = self.geocode(query, country_code)
        country_code ||= geo.country_code if geo
        # different formats have different acceptance criteria
        q = nil
        case format
        when :icao
          return nil unless geo && geo.address && geo.country
          q = "#{geo.address}, #{geo.country}"
        else
          return nil unless geo && geo.locality && geo.region && geo.country
          q = "#{geo.locality}, #{geo.region}, #{geo.country}"
        end
        return [q, country_code, geo]
      else
        # without geocoding, the best we can do is just make use the given query as
        # the query for the "geocode" format
        return [query, country_code, nil]
      end
      return nil
    end

    #
    # --- TODO ---
    # The following methods need more coverage tests
    #

    def self.has_geocode_key?
      # quick check to see that the Google API key exists for geocoding
      self.google_geocode_key && !self.google_geocode_key.nil?
    end
    
    # if Graticule exists, use it, otherwise use HTTParty
    def self.geocode(query, country_code=nil)   
      use_graticule = false
      unless Barometer::skip_graticule
        begin
          require 'rubygems'
          require 'graticule'
          $:.unshift(File.dirname(__FILE__))
          # load some changes to Graticule
          # TODO: attempt to get changes into Graticule gem
          require 'extensions/graticule'
          use_graticule = true
        rescue LoadError
          # do nothing, we will use HTTParty
        end
      end
  
      if use_graticule
        geo = self.geocode_graticule(query, country_code)
      else
        geo = self.geocode_httparty(query, country_code)
      end
      geo
    end
    
    def self.geocode_graticule(query, country_code=nil)
      return nil unless self.has_geocode_key?
      geocoder = Graticule.service(:google).new(self.google_geocode_key)
      location = geocoder.locate(query, country_code)
      geo = Barometer::Geo.new(location)
    end

    def self.geocode_httparty(query, country_code=nil)
      return nil unless self.has_geocode_key?
      location = Barometer::Service.get(
        "http://maps.google.com/maps/geo",
        :query => {
          :gl => country_code,
          :key => self.google_geocode_key,
          :output => "xml",
          :q => query
        },
        :format => :xml
      )['kml']['Response']
      geo = Barometer::Geo.new(location)
    end
    
    def self.format_to_country_code(format)
      return nil unless format
      case format
      when :zipcode
        country_code = "US"
      when :postalcode
        country_code = "CA"
      else
        country_code = nil
      end
      country_code
    end
    
    # todo, the fist letter in a 4-letter icao can designate country:
    # c=canada
    # k=usa
    # etc...
    # def self.icao_to_country_code(icao_code)
    #   return unless icao_code.is_a?(String)
    #   country_code = nil
    #   if icao_code.size == 4
    #     case icao_code.first_letter
    #     when "C"
    #       country_code = "CA"
    #     when "K"
    #       country_code = "US"
    #     end
    #     if coutry_code.nil?
    #       case icao_code.first_two_letters
    #       when "ET"
    #         country_code = "GERMANY"
    #       end
    #     end
    #   end  
    #   country_code
    # end

  end
end  
