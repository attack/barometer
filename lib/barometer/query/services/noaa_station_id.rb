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

          if doc
            extra_links = doc.search(".current-conditions-extra a")

            if sid_link = extra_links.detect{|link| link.attr('href').match(/sid=(.*)&/)}
              sid_link.attr('href').match(/sid=(.*?)&/)[1]
            elsif three_day_link = extra_links.detect{|link| link.text.match(/3 Day History/)}
              three_day_link.attr('href').match(/\/([A-Za-z]*?)\.html/)[1]
            end
          end
        rescue
          nil
        end
      end
    end
  end
end
