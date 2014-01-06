require_relative '../spec_helper'

module Barometer::Utils
  describe Payload do
    describe '#fetch' do
      it 'returns the value for the key provided' do
        hash = {one: 1}
        parser = Payload.new(hash)
        expect( parser.fetch(:one) ).to eq 1
      end

      it 'traverses multiple levels to get the value' do
        hash = {one: {two: {three: 3}}}
        parser = Payload.new(hash)
        expect( parser.fetch(:one, :two, :three) ).to eq 3
      end
    end

    describe '#units' do
      it 'returns the query units when the query is present' do
        units = double(:units)
        query = double(:query, units: units)

        payload = Payload.new({}, query)

        expect( payload.units ).to eq units
      end

      it 'returns nil when the query is not present' do
        payload = Payload.new({}, nil)
        expect( payload.units ).to be_nil
      end
    end
  end
end
