require_relative '../../spec_helper'

module Barometer::Query
  describe Service::GoogleGeocode, vcr: {
    cassette_name: 'Service::GoogleGeocode'
  } do
    describe '.call' do
      context 'when the query is a :zipcode' do
        it 'returns the correct Geo data' do
          query = Barometer::Query.new('90210')
          geo = Service::GoogleGeocode.new(query).call

          expect( geo.query ).to eq '90210'
          expect( geo.latitude ).to eq 34.1030032
          expect( geo.longitude ).to eq -118.4104684
          expect( geo.locality ).to eq 'Beverly Hills'
          expect( geo.region ).to eq 'CA'
          expect( geo.country ).to eq 'United States'
          expect( geo.country_code ).to eq 'US'
          expect( geo.address ).to be_nil
          expect( geo.postal_code ).to eq '90210'
        end
      end

      context 'when the query is a city/region' do
        it 'returns the correct Geo data' do
          query = Barometer::Query.new('New York, NY')
          geo = Service::GoogleGeocode.new(query).call

          expect( geo.query ).to eq 'New York, NY, US'
          expect( geo.latitude ).to eq 40.7143528
          expect( geo.longitude ).to eq -74.00597309999999
          expect( geo.locality ).to eq 'New York'
          expect( geo.region ).to eq 'NY'
          expect( geo.country ).to eq 'United States'
          expect( geo.country_code ).to eq 'US'
          expect( geo.address ).to be_nil
          expect( geo.postal_code ).to be_nil
        end
      end

      context 'when the query is :coordinates' do
        it 'returns the correct Geo data' do
          query = Barometer::Query.new('47,-114')
          geo = Service::GoogleGeocode.new(query).call

          expect( geo.query ).to be_nil
          expect( geo.latitude ).to eq 47.000623
          expect( geo.longitude ).to eq -114.0016495
          expect( geo.locality ).to eq 'Missoula'
          expect( geo.region ).to eq 'MT'
          expect( geo.country ).to eq 'United States'
          expect( geo.country_code ).to eq 'US'
          expect( geo.address ).to be_nil
          expect( geo.postal_code ).to eq '59808'
        end
      end
    end
  end
end
