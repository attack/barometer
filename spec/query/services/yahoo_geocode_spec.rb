require_relative '../../spec_helper'

module Barometer::Query
  describe Service::YahooGeocode, vcr: {
    cassette_name: 'Service::YahooGeocode'
  } do
    describe '#call' do
      context 'when the query format is unsupported' do
        let(:query) { Barometer::Query.new('90210') }

        it 'returns nothing' do
          geo = Service::YahooGeocode.new(query).call
          expect( geo ).to be_nil
        end

        context 'and a :woe_id conversion exists' do
          it 'returns the correct geo data' do
            query.add_conversion(:woe_id, '615702')
            geo = Service::YahooGeocode.new(query).call

            expect( geo.latitude ).to eq 48.85693
            expect( geo.longitude ).to eq 2.3412
            expect( geo.locality ).to eq 'Paris'
            expect( geo.region ).to eq 'Ile-de-France'
            expect( geo.country ).to eq 'France'
            expect( geo.country_code ).to eq 'FR'
            expect( geo.postal_code ).to eq '75001'

            expect( geo.query ).to be_nil
            expect( geo.address ).to be_nil
          end
        end
      end

      context 'when the query format is :woe_id' do
        it 'returns the correct geo data' do
          query = Barometer::Query.new('615702')
          geo = Service::YahooGeocode.new(query).call

          expect( geo.latitude ).to eq 48.85693
          expect( geo.longitude ).to eq 2.3412
          expect( geo.locality ).to eq 'Paris'
          expect( geo.region ).to eq 'Ile-de-France'
          expect( geo.country ).to eq 'France'
          expect( geo.country_code ).to eq 'FR'
          expect( geo.postal_code ).to eq '75001'

          expect( geo.query ).to be_nil
          expect( geo.address ).to be_nil
        end
      end

      context 'when the query format is :ipv4_address' do
        it 'returns the correct geo data' do
          query = Barometer::Query.new('8.8.8.8')
          geo = Service::YahooGeocode.new(query).call

          expect( geo.latitude ).to eq 37.418726
          expect( geo.longitude ).to eq -122.072037
          expect( geo.locality ).to eq 'Mountain View'
          expect( geo.region ).to eq 'CA'
          expect( geo.country_code ).to eq 'US'
          expect( geo.country ).to eq 'United States'
          expect( geo.postal_code ).to eq '94043'

          expect( geo.query ).to be_nil
          expect( geo.address ).to be_nil
        end
      end
    end
  end
end
