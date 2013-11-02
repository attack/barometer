require_relative '../../spec_helper'

module Barometer::Query
  describe Format::Icao do
    describe '.geo' do
      specify { expect( Format::Icao.geo(nil) ).to be_nil }
      specify { expect( Format::Icao.geo('KSFO') ).to eq({country_code: 'US'}) }
      specify { expect( Format::Icao.geo('CYYC') ).to eq({country_code: 'CA'}) }
      specify { expect( Format::Icao.geo('ETAA') ).to eq({country_code: 'DE'}) }
    end

    describe '.is?' do
      it 'recognizes a valid format' do
        expect( Format::Icao.is?('KSFO') ).to be_true
      end

      it 'recognizes non-valid format' do
        expect( Format::Icao.is?('invalid') ).to be_false
      end
    end
  end
end
