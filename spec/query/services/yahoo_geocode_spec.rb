require_relative '../../spec_helper'

module Barometer::Query
  describe Service::YahooGeocode, vcr: {
    cassette_name: 'Service::YahooGeocode'
  } do
    describe ".call" do
      context 'when the query format is neither :weather_id or :woe_id' do
        let(:query) { Barometer::Query.new('90210') }

        it 'returns nothing' do
          geo = Service::YahooGeocode.call(query)
          expect( geo ).to be_nil
        end

        context 'and a :weather_id conversion exists' do
          it 'returns the correct geo data' do
            query.add_conversion(:weather_id, 'USNY0996')
            geo = Service::YahooGeocode.call(query)

            expect( geo.latitude ).to eq 40.67
            expect( geo.longitude ).to eq -73.94
            expect( geo.locality ).to eq 'New York'
            expect( geo.region ).to eq 'NY'
            expect( geo.country_code ).to eq 'US'

            expect( geo.query ).to be_nil
            expect( geo.country ).to be_nil
            expect( geo.address ).to be_nil
            expect( geo.postal_code ).to be_nil
          end
        end

        context 'and a :woe_id conversion exists' do
          it 'returns the correct geo data' do
            query.add_conversion(:woe_id, '2459115')
            geo = Service::YahooGeocode.call(query)

            expect( geo.latitude ).to eq 40.71
            expect( geo.longitude ).to eq -74.01
            expect( geo.locality ).to eq 'New York'
            expect( geo.region ).to eq 'NY'
            expect( geo.country ).to eq 'United States'

            expect( geo.query ).to be_nil
            expect( geo.country_code ).to be_nil
            expect( geo.address ).to be_nil
            expect( geo.postal_code ).to be_nil
          end
        end
      end

      context 'when the query format is :weather_id' do
        it 'returns the correct geo data' do
          query = Barometer::Query.new('USNY0996')
          geo = Service::YahooGeocode.call(query)

          expect( geo.latitude ).to eq 40.67
          expect( geo.longitude ).to eq -73.94
          expect( geo.locality ).to eq 'New York'
          expect( geo.region ).to eq 'NY'
          expect( geo.country_code ).to eq 'US'

          expect( geo.query ).to be_nil
          expect( geo.country ).to be_nil
          expect( geo.address ).to be_nil
          expect( geo.postal_code ).to be_nil
        end
      end

      context 'when the query format is :woe_id' do
        it 'returns the correct geo data' do
          query = Barometer::Query.new('w2459115')
          geo = Service::YahooGeocode.call(query)

          expect( geo.latitude ).to eq 40.71
          expect( geo.longitude ).to eq -74.01
          expect( geo.locality ).to eq 'New York'
          expect( geo.region ).to eq 'NY'
          expect( geo.country ).to eq 'United States'

          expect( geo.query ).to be_nil
          expect( geo.country_code ).to be_nil
          expect( geo.address ).to be_nil
          expect( geo.postal_code ).to be_nil
        end
      end
    end
  end
end
