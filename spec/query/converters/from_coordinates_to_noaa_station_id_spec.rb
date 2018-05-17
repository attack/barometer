require_relative '../../spec_helper'

module Barometer
  module Query
    module Converter
      RSpec.describe FromCoordinatesToNoaaStationId, vcr: {
        match_requests_on: [:method, :uri],
        cassette_name: 'Converter::FromCoordinatesToNoaaStationId'
      } do

        it 'registers as a :coordinates -> :noaa_station_id converter' do
          result = Converter.find_all(:coordinates, :noaa_station_id)

          expect(result).to include(
            {noaa_station_id: Barometer::Query::Converter::FromCoordinatesToNoaaStationId}
          )
        end

        describe '.call' do
          it "converts :coordinates -> :noaa_station_id" do
            query = Query.new('34.10,-118.41')

            converter = FromCoordinatesToNoaaStationId.new(query)
            converted_query = converter.call

            expect(converted_query.q).to eq 'KSMO'
            expect(converted_query.format).to eq :noaa_station_id
          end

          it "uses a previous coversion (if needed) on the query" do
            query = Query.new('90210')
            query.add_conversion(:coordinates, '34.10,-118.41')

            converter = FromCoordinatesToNoaaStationId.new(query)
            converted_query = converter.call

            expect(converted_query.q).to eq 'KSMO'
            expect(converted_query.format).to eq :noaa_station_id
          end

          it "does not convert any other format" do
            query = Query.new('KJFK')
            converter = FromCoordinatesToNoaaStationId.new(query)
            expect(converter.call).to be_nil
          end
        end
      end
    end
  end
end
