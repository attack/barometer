require_relative 'apis/noaa_station'
require 'nokogiri'

module Barometer
  module Query
    module Service
      class NoaaStation
        def self.fetch(query)
          converted_query = query.get_conversion(:coordinates)
          return unless converted_query

          api = NoaaStation::Api.new(converted_query)
          _parse_content(api.get)
        end

        def self._parse_content(content)
          doc = Nokogiri::HTML.parse(content)
          if doc && links = doc.search(".current-conditions-extra a")
            sid_link = links.detect{|link| link.attr("href").match(/sid=(.*)&/)}
            sid_link.attr("href").match(/sid=(.*?)&/)[1]
          end
        rescue
          nil
        end
      end
    end
  end
end
