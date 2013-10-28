require_relative '../../spec_helper'

module Barometer::Query
  describe Service::FromWeatherId, vcr: {
    cassette_name: 'Service::FromWeatherId'
  } do
    describe '#call' do
      context 'when the query format is not :weather_id' do
        let(:query) { Barometer::Query.new('90210') }

        it 'returns nothing' do
          geo = Service::FromWeatherId.new(query).call
          expect( geo ).to be_nil
        end

        context 'and a :weather_id conversion exists' do
          it 'returns the correct geo data' do
            query.add_conversion(:weather_id, 'USNY0996')
            geo = Service::FromWeatherId.new(query).call

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
      end

      context 'when the query format is :weather_id' do
        it 'returns the correct geo data' do
          query = Barometer::Query.new('USNY0996')
          geo = Service::FromWeatherId.new(query).call

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
    end
  end
end
