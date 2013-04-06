module Barometer
  #
  # Format: Weather ID (specific to weather.com)
  #
  # eg. USGA0028
  #
  # This class is used to determine if a query is a
  # :weather_id, how to convert to and from :weather_id
  # and what the country_code is.
  #
  class Query::Format::WeatherID < Query::Format

    def self.format; :weather_id; end
    def self.regex; /(^[A-Za-z]{4}[0-9]{4}$)/; end
    def self.convertable_formats
      [:short_zipcode, :zipcode, :coordinates, :icao, :geocode]
    end

    # the first two letters of the :weather_id is the country_code
    #
    def self.country_code(query=nil)
      (query && query.size >= 2) ? _fix_country(query[0..1]) : nil
    end

    # convert to this format, X -> :weather_id
    #
    def self.to(original_query)
      raise ArgumentError unless is_a_query?(original_query)
      return nil unless converts?(original_query)

      # convert original query to :geocode, as that is the only
      # format we can convert directly from to weather_id
      converted_query = Barometer::Query.new
      converted_query = Query::Format::Geocode.to(original_query)
      converted_query.q = _search(converted_query)
      converted_query.format = format
      converted_query.country_code = country_code(converted_query.q)
      converted_query
    end

    # reverse lookup, :weather_id -> :geocode
    #
    def self.reverse(original_query)
      raise ArgumentError unless is_a_query?(original_query)
      return nil unless original_query.format == format
      converted_query = Barometer::Query.new
      converted_query.q = _reverse(original_query)
      converted_query.format = Query::Format::Geocode.format
      converted_query
    end

    private

    # :geocode -> :weather_id
    # search weather.com for the given query
    #
    def self._search(query=nil)
      return nil unless query
      raise ArgumentError unless is_a_query?(query)
      response = WebService::WeatherID.fetch(query)
      _parse_weather_id(response)
    end

    # :weather_id -> :geocode
    # query yahoo with :weather_id and parse geo_data
    #
    def self._reverse(query=nil)
      return nil unless query
      raise ArgumentError unless is_a_query?(query)
      response = WebService::WeatherID.reverse(query)
      _parse_geocode(response)
    end

    # match the first :weather_id (from search results)
    #
    def self._parse_weather_id(text)
      return nil unless text
      match = text.match(/loc id=[\\]?['|""]([0-9a-zA-Z]*)[\\]?['|""]/)
      match ? match[1] : nil
    end

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

Barometer::Query.register(:weather_id, Barometer::Query::Format::WeatherID)
