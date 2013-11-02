require_relative '../../spec_helper'

module Barometer::Query
  describe Format::Geocode do
    describe '.is?' do
      it 'returns false' do
        expect( Format::Geocode.is?('New York, NY') ).to be_false
      end
    end
  end
end
