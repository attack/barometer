require_relative '../spec_helper'

module Barometer::Data
  describe Geo do
    describe '#coordinates' do
      it 'joins latitude and longitude' do
        geo = Geo.new(
          longitude: '99.99',
          latitude: '88.88'
        )
        expect( geo.coordinates ).to eq '88.88,99.99'
      end
    end

    describe '#to_s' do
      it 'defaults to an empty string' do
        geo = Geo.new
        expect( geo.to_s ).to be_empty
      end

      it 'returns only the address' do
        geo = Geo.new(address: 'address')
        expect( geo.to_s ).to eq 'address'
      end

      it 'returns address + locality' do
        geo = Geo.new(
          address: 'address',
          locality: 'locality'
        )
        expect( geo.to_s ).to eq 'address, locality'
      end

      it 'returns address + locality + code' do
        geo = Geo.new(
          address: 'address',
          locality: 'locality',
          country_code: 'code'
        )
        expect( geo.to_s ).to eq 'address, locality, code'
      end
    end

    describe '#merge' do
      it 'returns a new Geo object' do
        target_geo = Geo.new
        source_geo = Geo.new

        geo = target_geo.merge(source_geo)
        expect( geo.object_id ).not_to eq target_geo.object_id
        expect( geo.object_id ).not_to eq source_geo.object_id
      end

      it 'uses original target values' do
        target_geo = Geo.new(
          locality: 'foo',
          postal_code: '90210'
        )
        source_geo = Geo.new(postal_code: '10001')

        geo = target_geo.merge(source_geo)
        expect( geo.locality ).to eq 'foo'
        expect( geo.postal_code ).to eq '90210'
      end

      it 'leaves blank target values' do
        target_geo = Geo.new(postal_code: '')
        source_geo = Geo.new(postal_code: '10001')

        geo = target_geo.merge(source_geo)
        expect( geo.postal_code ).to eq ''
      end

      it 'updates nil target values' do
        target_geo = Geo.new(country: nil)
        source_geo = Geo.new(country: 'Foo Bar')

        geo = target_geo.merge(source_geo)
        expect( geo.country ).to eq 'Foo Bar'
      end

      it 'updates unset target values' do
        target_geo = Geo.new
        source_geo = Geo.new(latitude: 12.34, longitude: -56.78)

        geo = target_geo.merge(source_geo)
        expect( geo.latitude ).to eq 12.34
        expect( geo.longitude ).to eq -56.78
      end
    end
  end
end
