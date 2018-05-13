require_relative '../../spec_helper'

module Barometer::Query
  RSpec.describe Service::YahooGeocode, vcr: {
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
            expect( geo.postal_code ).to be_nil

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
          expect( geo.postal_code ).to be_nil

          expect( geo.query ).to be_nil
          expect( geo.address ).to be_nil
        end
      end
    end
  end
end
