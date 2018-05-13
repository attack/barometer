require_relative '../../spec_helper'

module Barometer::Query
  RSpec.describe Service::ToWoeId, vcr: {
    cassette_name: 'Service::ToWoeId'
  } do
    describe '.call,' do
      it 'returns nothing if query is an unsupported format' do
        query = Barometer::Query.new('KSFO')
        expect( Service::ToWoeId.new(query).call ).to be_nil
      end

      it 'returns a weather_id if the query is format short_zipcode' do
        query = Barometer::Query.new('90210')
        expect( Service::ToWoeId.new(query).call ).to eq '12795711'
      end

      it 'returns a weather_id if the query is format zipcode' do
        query = Barometer::Query.new('10001-5555')
        expect( Service::ToWoeId.new(query).call ).to be_nil

        query = Barometer::Query.new('10001-5555')
        query.add_conversion(:short_zipcode, '10001')
        expect( Service::ToWoeId.new(query).call ).to eq '12761333'
      end

      it 'returns a weather_id if the query is format unknown' do
        query = Barometer::Query.new('Paris, France')
        expect( Service::ToWoeId.new(query).call ).to eq '615702'
      end

      it 'returns a weather_id if the query is format coordinates' do
        query = Barometer::Query.new('40.756054,-73.986951')
        expect( Service::ToWoeId.new(query).call ).to eq '91568254'
      end

      it 'returns a weather_id if the query is format postal code' do
        query = Barometer::Query.new('T5B 4M9')
        expect( Service::ToWoeId.new(query).call ).to eq '24354344'
      end

      it 'returns a weather_id if the query has a converted geocode' do
        query = Barometer::Query.new('KJFK')
        query.add_conversion(:short_zipcode, '10001')

        expect( Service::ToWoeId.new(query).call ).to eq '12761333'
      end
    end
  end
end
