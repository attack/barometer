require_relative '../../spec_helper'

module Barometer::Query
  describe Service::ToWoeId, vcr: {
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
        expect( Service::ToWoeId.new(query).call ).to eq '12761333'
      end

      it 'returns a weather_id if the query is format unknown' do
        query = Barometer::Query.new('Paris, France')
        expect( Service::ToWoeId.new(query).call ).to eq '12727257'
      end

      it 'returns a weather_id if the query is format coordinates' do
        query = Barometer::Query.new('40.756054,-73.986951')
        expect( Service::ToWoeId.new(query).call ).to eq '12761367'
      end

      it 'returns a weather_id if the query is format postal code' do
        query = Barometer::Query.new('T5B 4M9')
        expect( Service::ToWoeId.new(query).call ).to eq '12698082'
      end

      it 'returns a weather_id if the query is format ipv4 address' do
        query = Barometer::Query.new('98.139.183.24')
        expect( Service::ToWoeId.new(query).call ).to eq '12763119'
      end

      it 'returns a weather_id if the query has a converted geocode' do
        query = Barometer::Query.new('KJFK')
        query.add_conversion(:zipcode, '10001-5555')

        expect( Service::ToWoeId.new(query).call ).to eq '12761333'
      end
    end
  end
end
