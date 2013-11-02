require_relative '../../spec_helper'

module Barometer::Query
  describe Format::Base do
    describe '.is?' do
      it 'raises an error by default' do
        expect { Format::Base.is?('valid') }.to raise_error(NotImplementedError)
      end
    end

    describe '.geo' do
      specify { expect( Format::Base.geo(nil) ).to be_nil }
    end
  end
end
