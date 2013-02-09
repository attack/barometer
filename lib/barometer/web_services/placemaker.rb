module Barometer
  #
  # Web Service: Placemaker (by Yahoo!)
  #
  # Yahoo! Placemaker is a geoparsing web service,
  # this uses Placemaker to obtain a WOEID, as only Yahoo knows them
  #
  # accepts: city name, coords, postal code, NOT zip code, NOT icao
  #
  class WebService::Placemaker < WebService

    # get the woe_id for a given query
    #
    def self.fetch(query)

      begin
        require 'nokogiri'
      rescue LoadError
        puts "\n****\nTo use this functionality you will need to install Nokogiri >= 1.3.3\n****\n\n"
        return nil
      end

      puts "fetch woe_id: #{query.q}" if Barometer::debug?
      return nil unless query
      return nil unless _has_geocode_key?
      raise ArgumentError unless _is_a_query?(query)

      # BUG: httparty doesn't seem to post correctly
      # self.post(
      #   'http://wherein.yahooapis.com/v1/document',
      #   :query => {
      #     :documentType => "html",
      #     :outputType => 'xml',
      #     :documentContent => _adjust_query(query),
      #    :appid => Barometer.yahoo_placemaker_app_id
      #   }, :format => :xml, :timeout => Barometer.timeout
      # )

      # TODO: include timeout
      #   :timeout => Barometer.timeout
      #
      res = Net::HTTP.post_form(
        URI.parse("http://wherein.yahooapis.com/v1/document"),
        {
          'documentType' => 'text/html',
          'outputType' => 'xml',
          'documentContent' => _adjust_query(query),
          'appid' => Barometer.yahoo_placemaker_app_id
        }
      )

      Nokogiri::HTML.parse(res.body)
    end

    # get the location_data (geocode) for a given woe_id
    #
    def self.reverse(query)
      puts "reverse woe_id: #{query.q}" if Barometer::debug?
      return nil unless query
      raise ArgumentError unless _is_a_query?(query)
      self.get(
        "http://weather.yahooapis.com/forecastrss",
        :query => { :w => query.q },
        :format => :xml,
        :timeout => Barometer.timeout
      )['rss']['channel']["location"]
    end

    # parses a Nokogori doc object
    #
    def self.parse_woe_id(doc)
      doc.search('woeid').first.content
    end

    private

    # convert coordinates to a microformat version of coordinates
    # so that Placemaker uses them correctly
    #
    def self._adjust_query(query)
      output = query.q
      if query.format == :coordinates
        microformat = "<html><body><div class=\"geo\"><span class=\"latitude\">%s</span><span class=\"longitude\">%s</span></div></body></html>"
        output = sprintf(microformat, query.latitude, query.longitude)
      end
      puts "placemaker adjusted query: #{output}" if Barometer::debug?
      output
    end

    def self._has_geocode_key?
      !Barometer.yahoo_placemaker_app_id.nil?
    end

  end
end
