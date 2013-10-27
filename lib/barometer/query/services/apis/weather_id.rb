module Barometer
  module Query
    module Service
      class WeatherId
        class Api < Utils::Api
          def url
            'http://wxdata.weather.com/wxdata/search/search'
          end

          def params
            { where: format_query }
          end

          def unwrap_nodes
            ['search']
          end

          private

          # filter out words that weather.com has trouble geo-locating
          # mostly these are icao related
          #
          def format_query
            output = query.q.dup
            words_to_remove = %w(international airport municipal)
            words_to_remove.each do |word|
              output.gsub!(/#{word}/i, "")
            end
            output
          end
        end
      end
    end
  end
end
