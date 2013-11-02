require_relative '../../spec_helper'

module Barometer::Query
  describe Format::Postalcode do
    describe '.geo' do
      specify { expect( Format::Postalcode.geo(nil) ).to eq({country_code: 'CA'}) }
      specify { expect( Format::Postalcode.geo('ignored') ).to eq({country_code: 'CA'}) }
    end

    describe '.is?' do
      it 'recognizes a valid format' do
        expect( Format::Postalcode.is?('T5B 4M9') ).to be_true
      end

      it 'recognizes non-valid format' do
        expect( Format::Postalcode.is?('90210') ).to be_false
      end
    end
  end
end
