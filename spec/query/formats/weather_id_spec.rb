require_relative '../../spec_helper'

module Barometer::Query
  describe Format::WeatherID do
    describe '.geo' do
      specify { expect( Format::WeatherID.geo(nil) ).to be_nil }
      specify { expect( Format::WeatherID.geo('i') ).to be_nil }

      context 'when the country code is standard' do
        specify { expect( Format::WeatherID.geo('USGA0000') ).to eq({country_code: 'US'}) }
        specify { expect( Format::WeatherID.geo('CAAB0000') ).to eq({country_code: 'CA'}) }
      end

      context 'when the country code is non standard' do
        specify { expect( Format::WeatherID.geo('SPXX0000') ).to eq({country_code: 'ES'}) }
      end
    end

    describe '.is?' do
      it 'recognizes a valid format' do
        expect( Format::WeatherID.is?('USGA0028') ).to be_true
      end

      it 'recognizes non-valid format' do
        expect( Format::WeatherID.is?('invalid') ).to be_false
      end
    end
  end
end
