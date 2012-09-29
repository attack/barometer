module Barometer
  #
  # Format: WOEID
  #   "Where on Earth" ID (by Yahoo!)
  #
  # eg. 2459115, 615702 or w90210
  #
  # NOTE: zipcodes and WoeIDs can look exactly the same when the WoeID
  #   is 5 digits long.  For now, a 5 digit number will be detected as
  #   zipcode.  The way to override this is to prepend a number with the
  #   letter 'w'.  Therefore 90210 will be a zipcode and w90210 will be
  #   a WoeID.  In the future, if WoeIDs are moe popular then zipcodes,
  #   then I will reverse this ...
  #
  # This class is used to determine if a query is a
  # :woe_id and how to convert to a :woe_id.
  #
  class Query::Format::WoeID < Query::Format
  
    def self.format; :woe_id; end
    def self.regex; /(^[0-9]{4}$)|(^[0-9]{6,7}$)|(^w[0-9]{4,7}$)/; end
    def self.convertable_formats
      [:short_zipcode, :zipcode, :weather_id, :coordinates, :icao, :geocode, :postalcode]
    end
    
    # remove the 'w' from applicable queries (only needed for detection)
    #
    def self.convert_query(text)
      return nil unless text
      text.delete('w')
    end
    
    # convert to this format, X -> :woeid
    #
    def self.to(original_query)
      raise ArgumentError unless is_a_query?(original_query)
      return nil unless converts?(original_query)
    
      # pre-convert (:weather_id -> :geocode)
      #
      pre_query = nil
      if original_query.format == :weather_id
        pre_query = Barometer::Query::Format::WeatherID.reverse(original_query)
      end

      # pre-convert ([:short_zipcode, :zipcode, :postalcode, :icao] -> :geocode)
      #
      unless pre_query
        if [:short_zipcode, :zipcode, :icao].include?(original_query.format)
          unless pre_query = original_query.get_conversion(Barometer::Query::Format::Geocode.format)
            pre_query = Barometer::Query::Format::Geocode.to(original_query)
          end
        end
      end

      converted_query = Barometer::Query.new
      converted_query.country_code = original_query.country_code if original_query
      
      # TODO
      # use Geomojo.com (when no Yahoo! appid)
      #
      # if [:coordinates].include?(pre_query ? pre_query.format : original_query.format) &&
      #   Barometer.yahoo_placemaker_app_id.nil?
      #   converted_query.q = _query_geomojo(pre_query || original_query)
      #   converted_query.format = format
      # end

      # use Yahoo! Placemaker
      #
      if [:coordinates, :geocode, :postalcode].include?(pre_query ? pre_query.format : original_query.format) &&
        !Barometer.yahoo_placemaker_app_id.nil?
        converted_query.q = _query_placemaker(pre_query || original_query)
        converted_query.format = format
      end
      
      converted_query.geo = pre_query.geo if pre_query
      converted_query.country_code = pre_query.country_code if pre_query
      converted_query
    end
    
    # reverse lookup, :woe_id -> (:geocode || :coordinates)
    #
    def self.reverse(original_query)
      raise ArgumentError unless is_a_query?(original_query)
      return nil unless original_query.format == self.format
      converted_query = Barometer::Query.new
      converted_query.q = _reverse(original_query)
      converted_query.format = Barometer::Query::Format::Geocode.format
      converted_query
    end
    
    private
    
    # Yahoo! Placemaker
    # [:geocode,:coordinates] -> :woe_id
    #
    def self._query_placemaker(query=nil)
      return nil unless query
      raise ArgumentError unless is_a_query?(query)
      doc = Barometer::WebService::Placemaker.fetch(query)
      _parse_woe_from_placemaker(doc)
    end
    
    # Geomojo.com
    # [:coordinates] -> :woe_id
    #
    # def self._query_geomojo(query=nil)
    #   return nil unless query
    #   raise ArgumentError unless is_a_query?(query)
    #   doc = WebService::Geomojo.fetch(query)
    #   _parse_woe_from_geomojo(doc)
    # end
    
    # :woe_id -> :geocode
    # query yahoo with :woe_id and parse geo_data
    #
    def self._reverse(query=nil)
      return nil unless query
      raise ArgumentError unless is_a_query?(query)
      response = Barometer::WebService::Placemaker.reverse(query)
      _parse_geocode(response)
    end

    # match the first :woe_id (from search results)
    #   expects a Nokogiri doc
    #
    def self._parse_woe_from_placemaker(doc)
      return nil unless doc
      Barometer::WebService::Placemaker.parse_woe_id(doc)
    end
    
    # match the first :woe_id (from search results)
    #   expects a Nokogiri doc
    #
    # def self._parse_woe_from_geomojo(doc)
    #   return nil unless doc
    #   WebService::Geomojo.parse_woe_id(doc)
    # end

    # parse the geo_data
    #
    def self._parse_geocode(text)
      return nil unless text
      output = [text["city"], text["region"], _fix_country(text["country"])]
      output.delete("")
      output.compact.join(', ')
    end
    
  end
end