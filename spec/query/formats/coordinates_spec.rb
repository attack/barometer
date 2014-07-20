require_relative '../../spec_helper'

module Barometer::Query
  RSpec.describe Format::Coordinates do
    describe '.geo' do
      specify { expect( Format::Coordinates.geo(nil) ).to be_nil }

      it 'parses out the latitude and longitude' do
        expect( Format::Coordinates.geo('11.22,33.44') ).to eq({latitude: 11.22, longitude: 33.44})
      end
    end

    describe '.is?' do
      it 'returns true when valid' do
        expect( Format::Coordinates.is?('40.756054,-73.986951') ).to be true
      end

      it 'returns false when not valid' do
        expect( Format::Coordinates.is?('90210') ).to be false
      end
    end
  end
end
