require_relative '../../spec_helper'

module Barometer::Query
  describe Format::NoaaStationId do
    describe '.is?' do
      it 'returns false' do
        expect( Format::NoaaStationId.is?('') ).to be_false
      end
    end
  end
end
