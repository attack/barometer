require_relative '../spec_helper'

module Barometer::Data
  describe Location do
    describe '#coordinates' do
      it 'joins longitude and latitude' do
        location = Location.new(
          longitude: '99.99',
          latitude: '88.88'
        )
        expect( location.coordinates ).to eq '88.88,99.99'
      end
    end

    describe '#to_s' do
      it 'defaults to an empty string' do
        location = Location.new
        expect( location.to_s ).to be_empty
      end

      it 'returns only the name' do
        location = Location.new(name: 'name')
        expect( location.to_s ).to eq 'name'
      end

      it 'returns name + city' do
        location = Location.new(
          name: 'name',
          city: 'city'
        )
        expect( location.to_s ).to eq 'name, city'
      end

      it 'returns name + city + country_code' do
        location = Location.new(
          name: 'name',
          city: 'city',
          country_code: 'country_code'
        )
        expect( location.to_s ).to eq 'name, city, country_code'
      end

      it 'returns name + city + country' do
        location = Location.new(
          name: 'name',
          city: 'city',
          country_code: 'country_code',
          country: 'country'
        )
        expect( location.to_s ).to eq 'name, city, country'
      end

      it 'returns name + city + state_code + country' do
        location = Location.new(
          name: 'name',
          city: 'city',
          country: 'country',
          state_code: 'state_code'
        )
        expect( location.to_s ).to eq 'name, city, state_code, country'
      end

      it 'returns name + city + state_name + country' do
        location = Location.new(
          name: 'name',
          city: 'city',
          country: 'country',
          state_code: 'state_code',
          state_name: 'state_name'
        )
        expect( location.to_s ).to eq 'name, city, state_name, country'
      end
    end
  end
end
