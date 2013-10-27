require_relative '../spec_helper'

module Barometer::Data
  describe Coordinates do
    describe '#coordinates' do
      it 'joins latitude and longitude' do
        coordinates = Coordinates.new(
          longitude: '99.99',
          latitude: '88.88'
        )
        expect( coordinates.coordinates ).to eq '88.88,99.99'
      end
    end
  end
end
