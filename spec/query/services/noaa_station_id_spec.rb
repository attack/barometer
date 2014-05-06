require_relative '../../spec_helper'

module Barometer
  module Query
    module Service
      describe NoaaStation, vcr: {
        cassette_name: 'Service::NoaaStation'
      } do
        describe '.fetch' do
          it "returns nohing if query doesn't have coordinates format" do
            query = Query.new("90210")
            expect(NoaaStation.fetch(query)).to be_nil
          end

          it "returns a station_id if the query is format coordinates" do
            query = Query.new('34.10,-118.41')
            expect(NoaaStation.fetch(query)).to eq 'KSMO'
          end

          it "returns a station_id if the query is format coordinates" do
            query = Query.new('42.7243,-73.6927')
            expect(NoaaStation.fetch(query)).to eq 'KALB'
          end

          it "returns a station_id if the query has a corrdinates conversion" do
            query = Query.new('90210')
            query.add_conversion(:coordinates, '34.10,-118.41')
            expect(NoaaStation.fetch(query)).to eq 'KSMO'
          end
        end
      end
    end
  end
end
