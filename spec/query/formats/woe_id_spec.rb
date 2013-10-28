require_relative '../../spec_helper'

module Barometer::Query
  describe Format::WoeID do
    describe '.is?' do
      it 'recognizes a valid 4 digit code format' do
        expect( Format::WoeID.is?('8775') ).to be_true
      end

      it 'recognizes a valid 6 digit code format' do
        expect( Format::WoeID.is?('615702') ).to be_true
      end

      it 'recognizes a valid 7 digit code format' do
        expect( Format::WoeID.is?('2459115') ).to be_true
      end

      it 'recognizes a valid 5 digit code with a prepended "w"' do
        expect( Format::WoeID.is?('w90210') ).to be_true
      end

      it 'does not recognize a zip code' do
        expect( Format::WoeID.is?('90210') ).to be_false
      end

      it 'recognizes non-valid format' do
        expect( Format::WoeID.is?('USGA0028') ).to be_false
      end
    end

    describe '.convert_query' do
      it 'recognizes standard woe ids' do
        query_no_conversion = '2459115'
        query = Barometer::Query.new(query_no_conversion)
        expect( query.q ).to eq query_no_conversion
      end

      it 'removes the prefix from "w" prefixed queries' do
        query_with_conversion = 'w90210'
        query = Barometer::Query.new(query_with_conversion)
        expect( query.q ).to eq '90210'
      end
    end
  end
end
